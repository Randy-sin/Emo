import SwiftUI

// 添加页面枚举
enum EmotionRecordPage {
    case intensity
    case description
    case factors
}

// 情绪趋势数据结构
struct EmotionTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let intensity: Double
    let emoji: String
}

// 情绪分布数据结构
struct EmotionDistributionItem: Identifiable {
    let id = UUID()
    let type: EmotionType
    let count: Int
    let percentage: Double
}

class EmotionViewModel: ObservableObject {
    @Published var records: [EmotionRecord] = []
    @Published var isShowingBreathingSelection = false
    @Published var isShowingBreathingSession = false
    @Published var selectedEmotionType: EmotionType?
    @Published var selectedIntensity: Int = 3
    @Published var noteText: String = ""
    @Published var selectedTags: Set<String> = []
    @Published var selectedFactors: Set<String> = []
    @Published var emotionStats: EmotionStats?
    @Published var breathingRecords: [BreathingRecord] = []
    @Published var breathingStats: BreathingStats?
    @Published var selectedBreathingCycles: Int = 1
    @Published var currentPage: EmotionRecordPage = .intensity
    @Published var showEmotionSheet = false
    @Published var showQuickRecordSheet = false
    @Published var recentEmotions: [EmotionStorage.RecentEmotion] = []
    
    private let storage = EmotionStorage.shared
    private let breathingStorageKey = "breathing_records"
    
    init() {
        loadRecords()
        loadBreathingRecords()
        updateStats()
        loadRecentEmotions()
    }
    
    func loadRecords() {
        records = storage.getRecentRecords()
    }
    
    func updateStats() {
        emotionStats = storage.getEmotionStats()
    }
    
    func finishRecording() {
        recordEmotion()  // 先记录情绪
        showEmotionSheet = false  // 关闭整个 sheet
    }
    
    func recordEmotion() {
        guard let emotionType = selectedEmotionType else { return }
        
        let record = EmotionRecord(
            emoji: emotionType.rawValue,
            intensity: selectedIntensity,
            note: noteText.isEmpty ? nil : noteText,
            tags: Array(selectedTags),
            factors: Array(selectedFactors)
        )
        
        storage.saveRecord(record)
        loadRecords()
        updateStats()
        
        // 先显示呼吸训练选择界面
        withAnimation {
            isShowingBreathingSelection = true
        }
        
        // 最后再重置输入
        resetInput()
    }
    
    func startBreathingSession(cycles: Int) {
        selectedBreathingCycles = cycles
        isShowingBreathingSelection = false
        isShowingBreathingSession = true
    }
    
    func resetInput() {
        selectedEmotionType = nil
        selectedIntensity = 3
        noteText = ""
        selectedTags.removeAll()
        selectedFactors.removeAll()
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    func getSuggestedTags() -> [String] {
        selectedEmotionType?.suggestedTags ?? []
    }
    
    func getBreathingGuide() -> String {
        selectedEmotionType?.breathingGuide ?? "深呼吸..."
    }
    
    // 加载呼吸记录
    private func loadBreathingRecords() {
        if let data = UserDefaults.standard.data(forKey: breathingStorageKey),
           let records = try? JSONDecoder().decode([BreathingRecord].self, from: data) {
            breathingRecords = records
            updateBreathingStats()
        }
    }
    
    // 保存呼吸记录
    func saveBreathingRecord() {
        guard let emotionType = selectedEmotionType else { return }
        
        // 计算实际持续时间：每个周期 4+7+8=19秒
        let cycleDuration: TimeInterval = 19.0
        let totalDuration = cycleDuration * Double(selectedBreathingCycles)
        
        let record = BreathingRecord(
            cycles: selectedBreathingCycles,
            duration: totalDuration,
            emotionType: emotionType.rawValue
        )
        breathingRecords.append(record)
        
        if let encoded = try? JSONEncoder().encode(breathingRecords) {
            UserDefaults.standard.set(encoded, forKey: breathingStorageKey)
        }
        
        updateBreathingStats()
    }
    
    // 更新呼吸统计
    private func updateBreathingStats() {
        let calendar = Calendar.current
        let now = Date()
        
        let todayRecords = breathingRecords.filter {
            calendar.isDate($0.timestamp, inSameDayAs: now)
        }.sorted(by: { $0.timestamp < $1.timestamp })
        
        let lastWeekRecords = breathingRecords.filter {
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
            return $0.timestamp >= weekAgo
        }
        
        // 计算平均间隔时间
        var averageInterval: TimeInterval = 0
        if todayRecords.count >= 2 {
            let intervals = zip(todayRecords, todayRecords.dropFirst()).map { 
                $1.timestamp.timeIntervalSince($0.timestamp)
            }
            averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        }
        
        // 统计时段分布
        var distribution: [Int: Int] = [:]
        for record in lastWeekRecords {
            let hour = calendar.component(.hour, from: record.timestamp)
            distribution[hour, default: 0] += 1
        }
        
        breathingStats = BreathingStats(
            totalSessions: breathingRecords.count,
            todaySessions: todayRecords.count,
            lastWeekSessions: lastWeekRecords.count,
            timeDistribution: distribution,
            averageInterval: averageInterval,
            lastBreathingTime: breathingRecords.last?.timestamp,
            todayFirstTime: todayRecords.first?.timestamp,
            todayLastTime: todayRecords.last?.timestamp
        )
    }
    
    // 获取呼吸统计概要
    func getBreathingStatsText() -> String {
        guard let stats = breathingStats else { return "暂无数据" }
        
        var text = """
        今日呼吸练习: \(stats.todaySessions) 次
        本周呼吸练习: \(stats.lastWeekSessions) 次
        累计练习次数: \(stats.totalSessions) 次
        """
        
        if stats.todaySessions >= 2 {
            let averageHours = stats.averageInterval / 3600
            text += "\n平均练习间隔: \(String(format: "%.1f", averageHours))小时"
        }
        
        if let firstTime = stats.todayFirstTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            text += "\n今日首次练习: \(formatter.string(from: firstTime))"
        }
        
        return text
    }
    
    // 获取情绪统计概要
    func getEmotionSummary() -> String {
        guard let stats = emotionStats else { return "暂无数据" }
        
        var summary = stats.getSummary()
        
        // 添加情绪分布信息
        if let mostFrequent = stats.getMostFrequentEmotions(limit: 1).first {
            summary += "\n最常见的情绪: \(mostFrequent.0) (\(mostFrequent.1)次)"
        }
        
        // 添加标签信息
        let topTags = stats.getTopTags(limit: 3)
        if !topTags.isEmpty {
            summary += "\n常用标签: " + topTags.map { "\($0.0)(\($0.1)次)" }.joined(separator: ", ")
        }
        
        return summary
    }
    
    // 获取常用标签
    func getTopTags() -> [(tag: String, count: Int)] {
        guard let stats = emotionStats else { return [] }
        return stats.getTopTags()
    }
    
    // 加载最近使用的情绪
    private func loadRecentEmotions() {
        recentEmotions = storage.getRecentEmotions()
    }
    
    // 快速记录最近使用的情绪
    func quickRecord(_ emotion: EmotionStorage.RecentEmotion) {
        let record = EmotionRecord(
            emoji: emotion.type.rawValue,
            intensity: emotion.intensity,
            tags: Array(emotion.tags)
        )
        
        storage.saveRecord(record)
        loadRecords()
        updateStats()
        loadRecentEmotions()
        
        // 显示呼吸训练选择界面
        withAnimation {
            isShowingBreathingSelection = true
        }
    }
    
    // 获取推荐的情绪类型
    func getRecommendedEmotions() -> [EmotionType] {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<9: // 早晨
            return [.calm, .happy, .breathing]
        case 9..<12: // 上午
            return [.stress, .anxious, .breathing]
        case 12..<14: // 中午
            return [.calm, .stress, .breathing]
        case 14..<18: // 下午
            return [.stress, .tired, .breathing]
        case 18..<22: // 晚上
            return [.happy, .calm, .breathing]
        default: // 深夜
            return [.calm, .tired, .breathing]
        }
    }
    
    // 快速记录推荐的情绪
    func quickRecordRecommended(_ type: EmotionType) {
        let record = EmotionRecord(
            emoji: type.rawValue,
            intensity: 3,
            tags: Array(type.suggestedTags.prefix(3))
        )
        
        storage.saveRecord(record)
        loadRecords()
        updateStats()
        loadRecentEmotions()
        
        // 显示呼吸训练选择界面
        withAnimation {
            isShowingBreathingSelection = true
        }
    }
    
    // 获取情绪趋势数据
    func getEmotionTrend(for timeRange: HistoryView.TimeRange) -> [EmotionTrendPoint] {
        let records = storage.getAllRecords()
        let calendar = Calendar.current
        let now = Date()
        
        let days: Int
        switch timeRange {
        case .week:
            days = 7
        case .month:
            days = 30
        case .year:
            days = 365
        }
        
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: now) ?? now
        let filteredRecords = records.filter { $0.timestamp >= cutoffDate }
        
        return filteredRecords.map { record in
            EmotionTrendPoint(
                date: record.timestamp,
                intensity: Double(record.intensity),
                emoji: record.emoji
            )
        }.sorted { $0.date < $1.date }
    }
    
    // 获取情绪分布数据
    func getEmotionDistribution() -> [EmotionDistributionItem] {
        let records = storage.getAllRecords()
        var typeCounts: [EmotionType: Int] = [:]
        
        // 统计每种情绪类型的数量
        records.forEach { record in
            if let type = EmotionType(rawValue: record.emoji) {
                typeCounts[type, default: 0] += 1
            }
        }
        
        let total = Double(records.count)
        
        // 转换为分布项数组
        return typeCounts.map { type, count in
            EmotionDistributionItem(
                type: type,
                count: count,
                percentage: total > 0 ? (Double(count) / total) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
    }
    
    // 获取所有记录
    func getAllRecords() -> [EmotionRecord] {
        storage.getAllRecords()
    }
    
    // 检查情绪预警
    func checkEmotionAlert() -> EmotionAlert.AlertLevel {
        let records = storage.getRecentRecords(days: 1)  // 获取最近24小时的记录
        
        // 获取连续的负面情绪记录
        let negativeRecords = records.filter { record in
            guard let type = EmotionType(rawValue: record.emoji) else { return false }
            return type.category == .negative && record.intensity >= 3
        }
        
        // 检查是否触发预警
        for level in [EmotionAlert.AlertLevel.serious, .warning, .notice] {
            if let trigger = EmotionAlert.alertRules[level] {
                if negativeRecords.count >= trigger.consecutiveNegativeEmotions {
                    let highIntensityCount = negativeRecords.filter { 
                        $0.intensity >= trigger.negativeEmotionIntensity 
                    }.count
                    if highIntensityCount >= trigger.consecutiveNegativeEmotions {
                        return level
                    }
                }
            }
        }
        
        return .normal
    }
    
    // 获取情绪建议
    func getEmotionSuggestions() -> [EmotionAlert.Suggestion] {
        var suggestions: [EmotionAlert.Suggestion] = []
        
        // 获取最近的情绪记录
        if let lastRecord = records.first,
           let type = EmotionType(rawValue: lastRecord.emoji) {
            // 获取当前预警等级
            let alertLevel = checkEmotionAlert()
            // 添加特定情绪类型的建议
            suggestions = EmotionAlert.getSpecificSuggestions(for: type, level: alertLevel)
            
            // 如果没有特定建议，使用预警等级的通用建议
            if suggestions.isEmpty {
                suggestions = alertLevel.suggestions
            }
        }
        
        return suggestions
    }
    
    // 获取情绪状态描述
    func getEmotionStatusDescription() -> String {
        let alertLevel = checkEmotionAlert()
        var description = alertLevel.description
        
        if alertLevel != .normal {
            if let lastRecord = records.first,
               let type = EmotionType(rawValue: lastRecord.emoji) {
                description += "\n最近的情绪：\(type.description)"
            }
        }
        
        return description
    }
}
