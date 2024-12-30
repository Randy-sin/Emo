@preconcurrency import Vision
import UIKit

@globalActor actor VisionProcessing {
    static let shared = VisionProcessing()
}

@VisionProcessing
final class VisionProcessor {
    // Face detection request instance
    private static let faceDetectionRequest = VNDetectFaceLandmarksRequest()
    
    // Process image buffer for face and smile detection
    static func process(pixelBuffer: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if let error = error {
                print("Face detection error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else { return }
            
            for observation in observations {
                // Check for facial landmarks
                guard let landmarks = observation.landmarks else { continue }
                
                // Analyze smile
                if let mouth = landmarks.outerLips {
                    let mouthPoints = mouth.normalizedPoints
                    let isSmiling = Self.detectSmile(mouthPoints: mouthPoints)
                    
                    // Update UI on main thread
                    Task { @MainActor in
                        NotificationCenter.default.post(
                            name: Notification.Name("SmileDetected"),
                            object: nil,
                            userInfo: ["isSmiling": isSmiling]
                        )
                    }
                }
            }
        }
        
        // Create image request handler
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        // Perform detection request
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    // Analyze mouth points to detect smile
    // Note: For best results, show your teeth and make a big smile! 😁
    static func detectSmile(mouthPoints: [CGPoint]) -> Bool {
        // Check for sufficient mouth points
        guard mouthPoints.count >= 4 else {
            print("❌ Insufficient mouth points")
            return false
        }
        
        // Get key points
        let leftCorner = mouthPoints[0]      // Left mouth corner
        let rightCorner = mouthPoints[6]     // Right mouth corner
        let topCenter = mouthPoints[3]       // Top lip center
        let bottomCenter = mouthPoints[9]    // Bottom lip center
        
        // Calculate vertical distances (using y coordinates)
        let leftCornerToCenter = abs(leftCorner.y - ((topCenter.y + bottomCenter.y) / 2))
        let rightCornerToCenter = abs(rightCorner.y - ((topCenter.y + bottomCenter.y) / 2))
        
        // Calculate mouth openness
        let mouthOpenness = abs(topCenter.y - bottomCenter.y)
        
        print("""
        📏 Smile Detection Details:
        Left Corner: (\(leftCorner.x), \(leftCorner.y))
        Right Corner: (\(rightCorner.x), \(rightCorner.y))
        Top Center: (\(topCenter.x), \(topCenter.y))
        Bottom Center: (\(bottomCenter.x), \(bottomCenter.y))
        Left Corner Distance: \(leftCornerToCenter)
        Right Corner Distance: \(rightCornerToCenter)
        Mouth Openness: \(mouthOpenness)
        """)
        
        // Stricter smile detection criteria:
        // 1. At least one corner should be significantly distant from the center line (> 0.2)
        // 2. Both corners should show some movement (> 0.1)
        // 3. Mouth should be open enough (> 0.08)
        let hasSignificantCorner = leftCornerToCenter > 0.2 || rightCornerToCenter > 0.2
        let bothCornersMoving = leftCornerToCenter > 0.1 && rightCornerToCenter > 0.1
        let isOpenEnough = mouthOpenness > 0.08
        
        print("""
        🔍 Detection Results:
        Has Significant Corner: \(hasSignificantCorner)
        Both Corners Moving: \(bothCornersMoving)
        Is Open Enough: \(isOpenEnough)
        """)
        
        return hasSignificantCorner && bothCornersMoving && isOpenEnough
    }
}