import Foundation

struct BreathingRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let cycles: Int
    let duration: TimeInterval
    let emotionType: String  // 记录当时的情绪类型
    
    init(cycles: Int = 2, duration: TimeInterval = 30, emotionType: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.cycles = cycles
        self.duration = duration
        self.emotionType = emotionType
    }
}

struct BreathingStats: Codable {
    var totalSessions: Int
    var todaySessions: Int
    var lastWeekSessions: Int
    var timeDistribution: [Int: Int]  // 时段分布 (小时 -> 次数)
    var averageInterval: TimeInterval  // 平均间隔时间（秒）
    var lastBreathingTime: Date?      // 上次呼吸练习时间
    var todayFirstTime: Date?         // 今天第一次练习时间
    var todayLastTime: Date?          // 今天最后一次练习时间
} 