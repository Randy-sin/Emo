import Foundation
import AVFoundation

class AudioConverter {
    enum ConversionError: LocalizedError {
        case readError
        case writeError
        case formatError
        case conversionFailed(Error)
        case emptyFile
        
        var errorDescription: String? {
            switch self {
            case .readError: return "无法读取音频文件"
            case .writeError: return "无法写入转换后的文件"
            case .formatError: return "音频格式设置失败"
            case .conversionFailed(let error): return "转换失败: \(error.localizedDescription)"
            case .emptyFile: return "转换后的文件为空"
            }
        }
    }
    
    static func convertToWAV(_ sourceURL: URL) async throws -> URL {
        print("开始转换音频格式...")
        print("源文件: \(sourceURL)")
        
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("converted_\(UUID().uuidString).wav")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        do {
            // 1. 读取源文件
            let audioFile = try AVAudioFile(forReading: sourceURL)
            print("源文件格式: \(audioFile.processingFormat)")
            print("源文件长度: \(audioFile.length) 帧")
            
            // 2. 设置输出格式
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            
            // 3. 创建输出格式
            guard let outputFormat = AVAudioFormat(settings: outputSettings) else {
                throw ConversionError.formatError
            }
            
            // 4. 创建转换器
            guard let converter = AVAudioConverter(from: audioFile.processingFormat, to: outputFormat) else {
                throw ConversionError.formatError
            }
            
            // 5. 创建输出文件
            let outputFile = try AVAudioFile(
                forWriting: outputURL,
                settings: outputSettings
            )
            
            // 6. 创建输入缓冲区
            let frameCount = 4096
            let inputBuffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(frameCount)
            )!
            
            // 7. 创建输出缓冲区
            let ratio = outputFormat.sampleRate / audioFile.processingFormat.sampleRate
            let outputBuffer = AVAudioPCMBuffer(
                pcmFormat: outputFormat,
                frameCapacity: AVAudioFrameCount(Double(frameCount) * ratio)
            )!
            
            // 8. 分块读取和转换
            while audioFile.framePosition < audioFile.length {
                // 读取输入数据
                try audioFile.read(into: inputBuffer)
                
                // 转换
                var error: NSError?
                let status = converter.convert(to: outputBuffer, error: &error) { _, outStatus in
                    outStatus.pointee = .haveData
                    return inputBuffer
                }
                
                if let error = error {
                    throw ConversionError.conversionFailed(error)
                }
                
                if status == .error {
                    throw ConversionError.conversionFailed(NSError(domain: "AudioConverter", code: -1))
                }
                
                // 写入输出文件
                try outputFile.write(from: outputBuffer)
                
                // 重置缓冲区
                inputBuffer.frameLength = 0
                outputBuffer.frameLength = 0
            }
            
            // 9. 验证输出
            let verificationFile = try AVAudioFile(forReading: outputURL)
            print("验证输出格式: \(verificationFile.processingFormat)")
            print("验证文件长度: \(verificationFile.length) 帧")
            
            if verificationFile.length == 0 {
                throw ConversionError.emptyFile
            }
            
            print("音频转换成功")
            print("输出文件: \(outputURL)")
            
            return outputURL
            
        } catch {
            print("转换过程出错: \(error)")
            throw ConversionError.conversionFailed(error)
        }
    }
    
    static func cleanupTempFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            for file in files where file.lastPathComponent.hasPrefix("converted_") {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("清理临时文件失败: \(error)")
        }
    }
} 