import CoreHaptics
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var isEngineRunning = false
    
    private init() {
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.resetHandler = { [weak self] in
                self?.isEngineRunning = false
                print("Haptic engine reset")
                try? self?.engine?.start()
            }
            
            engine?.stoppedHandler = { [weak self] reason in
                self?.isEngineRunning = false
                print("Haptic engine stopped: \(reason)")
            }
            
            isEngineRunning = true
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    func startBreathingHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            // 修改呼吸模式的参数曲线，一次循环19秒（吸气4秒，屏息7秒，呼气8秒）
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    // 吸气阶段（4秒）
                    .init(relativeTime: 0.0, value: 0.3),    // 开始吸气
                    .init(relativeTime: 2.0, value: 0.7),    // 吸气中段
                    .init(relativeTime: 4.0, value: 0.5),    // 吸气完成
                    
                    // 屏息阶段（7秒）
                    .init(relativeTime: 7.0, value: 0.5),    // 屏息中段
                    .init(relativeTime: 11.0, value: 0.5),   // 屏息结束
                    
                    // 呼气阶段（8秒）
                    .init(relativeTime: 15.0, value: 0.7),   // 呼气中段
                    .init(relativeTime: 19.0, value: 0.3),   // 呼气结束
                ],
                relativeTime: 0)
            
            let breatheEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 19.0)  // 总持续时间改为19秒
            
            let pattern = try CHHapticPattern(events: [breatheEvent],
                                            parameterCurves: [intensityCurve])
            
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            continuousPlayer?.loopEnabled = true
            
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    func stopBreathingHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to stop haptic pattern: \(error)")
        }
    }
    
    // 简单的触觉反馈
    func playFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
