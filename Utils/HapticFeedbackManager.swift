import CoreHaptics
import UIKit

class HapticFeedbackManager {
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var isEngineRunning = false
    
    init() {
        setupHapticEngine()
    }
    
    // 添加错误处理包装器
    private func withErrorHandling(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            print("触觉反馈失败: \(error.localizedDescription)")
        }
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isEngineRunning = true
            
            // 引擎停止时的处理
            engine?.stoppedHandler = { reason in
                self.isEngineRunning = false
            }
            
            // 引擎重置时的处理
            engine?.resetHandler = {
                do {
                    try self.engine?.start()
                    self.isEngineRunning = true
                } catch {
                    print("重启触觉引擎失败: \(error.localizedDescription)")
                }
            }
        } catch {
            print("创建触觉引擎失败: \(error.localizedDescription)")
        }
    }
    
    // 吸气阶段的触觉反馈
    func startInhaleHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        withErrorHandling {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            
            // 创建渐强的触觉模式
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 4.0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        }
    }
    
    // 屏气阶段的触觉反馈
    func startHoldHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        withErrorHandling {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            
            // 创建间歇性的触觉模式
            var events: [CHHapticEvent] = []
            for i in 0..<3 {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: TimeInterval(i) * 2.0
                )
                events.append(event)
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        }
    }
    
    // 呼气阶段的触觉反馈
    func startExhaleHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        withErrorHandling {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            
            // 创建渐弱的触觉模式
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 8.0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        }
    }
    
    // 停止当前的触觉反馈
    func stopHaptics() {
        withErrorHandling {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        }
    }
} 