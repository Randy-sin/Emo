import SwiftUI

enum BreathingPhase: CaseIterable {
    case inhale
    case hold
    case exhale
    
    var description: String {
        switch self {
        case .inhale: return "吸气"
        case .hold: return "屏息"
        case .exhale: return "呼气"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .inhale: return 4.0
        case .hold: return 4.0
        case .exhale: return 6.0
        }
    }
}

class BreathingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var isActive: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentCycle: Int = 0
    @Published var totalTime: TimeInterval = 0
    @Published var isSessionComplete: Bool = false
    
    // MARK: - Callbacks
    var onComplete: (() -> Void)?
    var onPhaseChange: ((BreathingPhase) -> Void)?
    
    // MARK: - Private Properties
    private var timer: Timer?
    private let cycleCount: Int
    private var startTime: Date?
    private var lastPhaseChangeTime: Date?
    private var completedPhases: Int = 0
    private var pausedTime: TimeInterval = 0
    private let hapticManager = HapticFeedbackManager()
    
    // MARK: - Computed Properties
    var currentPhaseTimeRemaining: TimeInterval {
        guard let lastChange = lastPhaseChangeTime else { return 0 }
        let elapsed = Date().timeIntervalSince(lastChange)
        return max(0, currentPhase.duration - elapsed)
    }
    
    var totalProgress: Double {
        let totalDuration = BreathingPhase.allCases.reduce(0) { $0 + $1.duration } * Double(cycleCount)
        return min(1.0, totalTime / totalDuration)
    }
    
    // MARK: - Initialization
    init(cycles: Int = 1, onComplete: (() -> Void)? = nil) {
        self.cycleCount = cycles
        self.onComplete = onComplete
    }
    
    // MARK: - Public Methods
    func startSession() {
        isActive = true
        currentCycle = 0
        progress = 0.0
        totalTime = 0
        completedPhases = 0
        isSessionComplete = false
        startTime = Date()
        lastPhaseChangeTime = Date()
        startTimer()
        startPhaseHaptics()
    }
    
    func pauseSession() {
        guard isActive else { return }
        isActive = false
        timer?.invalidate()
        timer = nil
        if let last = lastPhaseChangeTime {
            pausedTime += Date().timeIntervalSince(last)
        }
        hapticManager.stopHaptics()
    }
    
    func resumeSession() {
        guard !isActive else { return }
        isActive = true
        lastPhaseChangeTime = Date()
        startTimer()
        startPhaseHaptics()
    }
    
    func endSession() {
        pauseSession()
        progress = 0.0
        totalTime = 0
        currentCycle = 0
        currentPhase = .inhale
        completedPhases = 0
        pausedTime = 0
        startTime = nil
        lastPhaseChangeTime = nil
        isSessionComplete = true
        onComplete?()
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc private func updateProgress() {
        guard isActive, let lastChange = lastPhaseChangeTime else { return }
        
        // 更新总时间
        if let start = startTime {
            totalTime = Date().timeIntervalSince(start) - pausedTime
        }
        
        // 更新当前阶段进度
        let elapsedInPhase = Date().timeIntervalSince(lastChange)
        let currentPhaseDuration = currentPhase.duration
        
        // 更新进度（确保不超过1.0）
        progress = min(elapsedInPhase / currentPhaseDuration, 1.0)
        
        // 检查是否需要进入下一阶段
        if elapsedInPhase >= currentPhaseDuration {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        let phases = BreathingPhase.allCases
        let currentIndex = phases.firstIndex(of: currentPhase)!
        let nextIndex = (currentIndex + 1) % phases.count
        
        // 检查是否完成一个完整周期
        if nextIndex == 0 {
            currentCycle += 1
            if currentCycle >= cycleCount {
                isSessionComplete = true
                onComplete?()
                endSession()
                return
            }
        }
        
        // 停止当前阶段的触觉反馈
        hapticManager.stopHaptics()
        
        // 更新到下一阶段
        completedPhases += 1
        currentPhase = phases[nextIndex]
        lastPhaseChangeTime = Date()
        onPhaseChange?(currentPhase)
        
        // 开始新阶段的触觉反馈
        startPhaseHaptics()
    }
    
    private func startPhaseHaptics() {
        switch currentPhase {
        case .inhale:
            hapticManager.startInhaleHaptics()
        case .hold:
            hapticManager.startHoldHaptics()
        case .exhale:
            hapticManager.startExhaleHaptics()
        }
    }
} 