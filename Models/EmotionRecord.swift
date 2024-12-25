import Foundation
import SwiftUI

struct EmotionRecord: Identifiable, Codable {
    let id: UUID
    let emoji: String
    let timestamp: Date
    let intensity: Int // 情绪强度 1-5
    let note: String? // 可选的笔记
    let tags: [String] // 情绪标签
    let factors: [String] // 影响因素
    
    init(emoji: String, intensity: Int = 3, note: String? = nil, tags: [String] = [], factors: [String] = [], timestamp: Date = Date()) {
        self.id = UUID()
        self.emoji = emoji
        self.intensity = max(1, min(5, intensity))
        self.note = note
        self.tags = tags
        self.factors = factors
        self.timestamp = timestamp
    }
}

// 预定义的情绪类型
enum EmotionType: String, CaseIterable, Codable {
    case happy = "开心"
    case calm = "平静"
    case anxious = "焦虑"
    case stress = "压力"
    case angry = "生气"
    case breathing = "呼吸"
    case closing = "结束"
    case inhalation = "吸气"
    case inflation = "膨胀"
    case joyful = "快乐"
    case pardons = "原谅"
    case rhythms = "节奏"
    case tired = "疲惫"
    case etc = "其他"
    
    var description: String {
        switch self {
        case .happy: return "开心愉悦"
        case .calm: return "平静安宁"
        case .anxious: return "焦虑不安"
        case .stress: return "压力紧张"
        case .angry: return "生气愤怒"
        case .breathing: return "深呼吸"
        case .closing: return "完成结束"
        case .inhalation: return "深呼吸"
        case .inflation: return "成长提升"
        case .joyful: return "欢乐喜悦"
        case .pardons: return "宽恕原谅"
        case .rhythms: return "韵律节奏"
        case .tired: return "疲惫困乏"
        case .etc: return "其他情绪"
        }
    }
    
    var color: Color {
        switch self {
        case .happy, .joyful:
            return .blue
        case .calm, .breathing, .inhalation:
            return .green
        case .anxious, .stress:
            return .orange
        case .angry:
            return .red
        case .tired:
            return .purple
        case .inflation, .pardons, .rhythms:
            return .mint
        case .closing, .etc:
            return .gray
        }
    }
    
    var category: EmotionCategory {
        switch self {
        case .happy, .calm, .joyful:
            return .positive
        case .anxious, .stress, .angry, .tired:
            return .negative
        case .breathing, .closing, .inhalation, .inflation, .pardons, .rhythms, .etc:
            return .neutral
        }
    }
    
    var suggestedTags: [String] {
        switch self {
        case .happy:
            return ["开心", "愉快", "成就感", "好消息", "家人", "朋友", "满意", "幸福", "感恩", "期待", "轻松", "温暖", "甜蜜", "放松", "充实"]
        case .calm:
            return ["平静", "放松", "安宁", "冥想", "休息", "音乐", "舒适", "宁静", "祥和", "自在", "淡然", "从容", "悠闲", "恬静", "安详"]
        case .anxious:
            return ["焦虑", "不安", "担心", "压力", "deadline", "考试", "紧张", "慌乱", "恐惧", "烦躁", "坐立不安", "心慌", "忧虑", "惶恐", "困扰"]
        case .stress:
            return ["压力", "紧张", "疲惫", "工作", "学习", "健康", "透支", "负担", "沉重", "不堪重负", "身心俱疲", "心力交瘁", "筋疲力尽", "精疲力竭", "压抑"]
        case .angry:
            return ["生气", "愤怒", "烦躁", "冲突", "不公", "受委屈", "恼火", "暴躁", "气愤", "怒火中烧", "忿怒", "愤懑", "不满", "憋屈", "怨恨"]
        case .breathing:
            return ["呼吸练习", "冥想", "放松", "减压", "专注", "平和", "调息", "沉淀", "内观", "觉察", "清醒", "回归", "静心", "调节", "疗愈"]
        case .closing:
            return ["结束", "完成", "告别", "休息", "新开始", "收尾", "圆满", "总结", "交接", "毕业", "离别", "转折", "蜕变", "转机", "希望"]
        case .inhalation:
            return ["深呼吸", "放松", "专注", "平静", "调节", "吸气", "屏气", "呼气", "节奏", "韵律", "缓和", "舒缓", "调息", "平衡", "和谐"]
        case .inflation:
            return ["扩展", "成长", "进步", "突破", "提升", "发展", "蜕变", "超越", "跨越", "升华", "拓展", "延伸", "扩充", "增长", "精进"]
        case .joyful:
            return ["快乐", "欢乐", "兴奋", "庆祝", "惊喜", "雀跃", "喜悦", "欣喜", "欢欣", "愉悦", "欢快", "欢腾", "欢畅", "欢欣鼓舞", "心花怒放"]
        case .pardons:
            return ["原谅", "宽恕", "理解", "和解", "释怀", "包容", "谅解", "化解", "宽容", "释然", "豁达", "开明", "海涵", "谅解", "释怀"]
        case .rhythms:
            return ["节奏", "韵律", "音乐", "运动", "舞蹈", "律动", "旋律", "和声", "协调", "动感", "摇摆", "跳跃", "轻盈", "飘逸", "灵动"]
        case .tired:
            return ["疲惫", "困乏", "乏力", "无力", "倦怠", "劳累", "精疲力竭", "昏昏欲睡", "没精神", "疲乏", "困倦", "疲不堪", "身心疲惫", "萎靡", "虚弱"]
        case .etc:
            return ["其他", "未分类", "特殊", "复杂", "混合", "难以形容", "说不清", "模糊", "多变", "不确定", "难以界定", "难以描述", "不明确", "待定", "待探索"]
        }
    }
    
    var breathingGuide: String {
        switch self {
        case .anxious:
            return "让我们做几次深呼吸，缓解焦虑..."
        case .stress:
            return "深呼吸能帮助缓解压力，放松身心..."
        case .angry:
            return "通过深呼吸平复情绪，找回平静..."
        case .breathing, .inhalation:
            return "跟随节奏，慢慢呼吸，感受平静..."
        case .closing:
            return "做几次深呼吸，结束这一刻..."
        case .pardons:
            return "深呼吸，放下，原谅..."
        case .rhythms:
            return "跟随呼吸的节奏，找到内心的平静..."
        default:
            return "让我们通过呼吸，感受当下..."
        }
    }
}

enum EmotionCategory {
    case positive
    case neutral
    case negative
    
    var color: String {
        switch self {
        case .positive: return "AccentColor"
        case .neutral: return "NeutralColor"
        case .negative: return "NegativeColor"
        }
    }
}

// 用于管理情绪记录的存储和检索
class EmotionStorage {
    static let shared = EmotionStorage()
    private let defaults = UserDefaults.standard
    private let storageKey = "emotionRecords"
    private let recentEmotionsKey = "recentEmotions"
    
    private init() {}
    
    // 最近使用的情绪记录结构
    struct RecentEmotion: Codable {
        let type: EmotionType
        let tags: Set<String>
        let intensity: Int
        let timestamp: Date
        
        init(record: EmotionRecord) {
            self.type = EmotionType(rawValue: record.emoji) ?? .etc
            self.tags = Set(record.tags)
            self.intensity = record.intensity
            self.timestamp = record.timestamp
        }
    }
    
    func saveRecord(_ record: EmotionRecord) {
        // 保存记录
        var records = getAllRecords()
        records.append(record)
        if let encoded = try? JSONEncoder().encode(records) {
            defaults.set(encoded, forKey: storageKey)
        }
        
        // 更新最近使用的情绪
        updateRecentEmotions(with: record)
    }
    
    // 更新最近使用的情绪
    private func updateRecentEmotions(with record: EmotionRecord) {
        var recentEmotions = getRecentEmotions()
        let newEmotion = RecentEmotion(record: record)
        
        // 如果已经存在相同类型的情绪，移除它
        recentEmotions.removeAll { $0.type.rawValue == record.emoji }
        
        // 添加新的情绪到开头
        recentEmotions.insert(newEmotion, at: 0)
        
        // 只保留最近5个
        if recentEmotions.count > 5 {
            recentEmotions = Array(recentEmotions.prefix(5))
        }
        
        // 保存
        if let encoded = try? JSONEncoder().encode(recentEmotions) {
            defaults.set(encoded, forKey: recentEmotionsKey)
        }
    }
    
    // 获取最近使用的情绪
    func getRecentEmotions() -> [RecentEmotion] {
        guard let data = defaults.data(forKey: recentEmotionsKey),
              let recentEmotions = try? JSONDecoder().decode([RecentEmotion].self, from: data) else {
            return []
        }
        return recentEmotions
    }
    
    func getAllRecords() -> [EmotionRecord] {
        guard let data = defaults.data(forKey: storageKey),
              let records = try? JSONDecoder().decode([EmotionRecord].self, from: data) else {
            return []
        }
        return records.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func getRecentRecords(days: Int = 7) -> [EmotionRecord] {
        let records = getAllRecords()
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return records.filter { record in
            record.timestamp >= cutoffDate
        }
    }
    
    func getEmotionStats(days: Int = 7) -> EmotionStats {
        let records = getRecentRecords(days: days)
        var stats = EmotionStats()
        
        records.forEach { record in
            stats.totalCount += 1
            stats.averageIntensity += Double(record.intensity)
            
            // 使用 rawValue 进行匹配
            if let emotionType = EmotionType(rawValue: record.emoji) {
                stats.emotionTypeCounts[emotionType, default: 0] += 1
            }
            
            record.tags.forEach { tag in
                stats.tagCounts[tag, default: 0] += 1
            }
        }
        
        if stats.totalCount > 0 {
            stats.averageIntensity /= Double(stats.totalCount)
        }
        
        return stats
    }
}

// 情绪统计数据结构
struct EmotionStats {
    var totalCount: Int = 0
    var averageIntensity: Double = 0
    var emotionTypeCounts: [EmotionType: Int] = [:]  // 使用 EmotionType 计数
    var tagCounts: [String: Int] = [:]
    
    var mostFrequentEmotion: (type: EmotionType, count: Int)? {
        if let max = emotionTypeCounts.max(by: { $0.value < $1.value }) {
            return (type: max.key, count: max.value)
        }
        return nil
    }
    
    var formattedMostFrequentEmotion: String {
        guard let most = mostFrequentEmotion else {
            return "无数据"
        }
        return "\(most.type.rawValue)（\(most.count)次）"
    }
    
    // 获取统计摘要
    func getSummary() -> String {
        return "共记录 \(totalCount) 次情绪，平均强度 \(String(format: "%.1f", averageIntensity))"
    }
    
    // 获取最常见的情绪
    func getMostFrequentEmotions(limit: Int = 3) -> [(EmotionType, Int)] {
        return Array(emotionTypeCounts.sorted { $0.value > $1.value }.prefix(limit))
            .map { ($0.key, $0.value) }
    }
    
    // 获取最常用的标签
    func getTopTags(limit: Int = 3) -> [(String, Int)] {
        return Array(tagCounts.sorted { $0.value > $1.value }.prefix(limit))
            .map { ($0.key, $0.value) }
    }
}
