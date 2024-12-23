import Foundation
import Speech

class SpeechRecognitionService {
    static func transcribe(audioFileURL: URL) async throws -> String {
        // 检查语音识别权限
        try await requestSpeechRecognitionPermission()
        
        // 创建语音识别请求
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
        let request = SFSpeechURLRecognitionRequest(url: audioFileURL)
        
        // 执行识别
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
    
    private static func requestSpeechRecognitionPermission() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .authorized:
                    continuation.resume()
                case .denied:
                    continuation.resume(throwing: 
                        NSError(domain: "SpeechRecognition", 
                               code: -1, 
                               userInfo: [NSLocalizedDescriptionKey: "语音识别权限被拒绝"]))
                case .restricted:
                    continuation.resume(throwing: 
                        NSError(domain: "SpeechRecognition", 
                               code: -2, 
                               userInfo: [NSLocalizedDescriptionKey: "语音识别功能受限"]))
                case .notDetermined:
                    continuation.resume(throwing: 
                        NSError(domain: "SpeechRecognition", 
                               code: -3, 
                               userInfo: [NSLocalizedDescriptionKey: "语音识别权限未确定"]))
                @unknown default:
                    continuation.resume(throwing: 
                        NSError(domain: "SpeechRecognition", 
                               code: -4, 
                               userInfo: [NSLocalizedDescriptionKey: "未知错误"]))
                }
            }
        }
    }
} 