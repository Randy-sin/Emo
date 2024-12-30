@preconcurrency import Vision
import UIKit
import AVFoundation

/// 管理摄像头会话并显示预览
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
    private var videoOutput: AVCaptureVideoDataOutput!
    // 添加专门的视觉处理队列
    private let visionQueue = DispatchQueue(label: "com.vision.queue")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera() // 初始化摄像头
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // 支持所有方向，但在 viewWillAppear 中设置为横屏
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    private func setupCamera() {
        // 创建捕获会话
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // 获取前置摄像头
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Unable to access camera")
            return
        }

        do {
            // 设置摄像头输入
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }

            // 设置视频输出
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            // 设置视频方向
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .landscapeRight
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }

            // 设置预览层
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            
            // 调整预览层大小和方向
            let bounds = view.bounds
            let previewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            previewLayer.frame = previewFrame
            previewLayer.connection?.videoOrientation = .landscapeRight
            
            view.layer.addSublayer(previewLayer)

            // 开始捕获会话
            captureSession.startRunning()
        } catch {
            print("Camera initialization failed: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置为横屏
        let windowScene = view.window?.windowScene
        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    // 显式标记此方法为非隔离的
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("⚠️ 无法获取 pixelBuffer")
            return
        }
        
        // 在队列中处理 Vision 请求，使用正确的图像方向
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
        let request = VNDetectFaceLandmarksRequest()
        
        visionQueue.async { [weak self] in
            do {
                try handler.perform([request])
                guard let observations = request.results else {
                    print("⚠️ 未检测到任何结果")
                    return
                }
                print("✅ 检测到 \(observations.count) 个面部")
                Task { @MainActor in
                    await self?.handleSmileDetection(observations)
                }
            } catch {
                print("❌ Vision error: \(error)")
            }
        }
    }
    
    @MainActor
    private func handleSmileDetection(_ observations: [VNFaceObservation]) async {
        for observation in observations {
            if let landmarks = observation.landmarks {
                print("✅ 检测到面部特征点")
                if let mouth = landmarks.outerLips {
                    print("✅ 检测到嘴部轮廓")
                    let mouthPoints = mouth.normalizedPoints
                    print("👄 嘴部点位：\(mouthPoints)")
                    let isSmiling = await VisionProcessor.detectSmile(mouthPoints: mouthPoints)
                    print("😊 微笑检测结果：\(isSmiling)")
                    NotificationCenter.default.post(
                        name: Notification.Name("SmileDetected"),
                        object: nil,
                        userInfo: ["isSmiling": isSmiling]
                    )
                } else {
                    print("⚠️ 未检测到嘴部轮廓")
                }
            } else {
                print("⚠️ 未检测到面部特征点")
            }
        }
    }
}
