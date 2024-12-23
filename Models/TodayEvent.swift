import Foundation

struct TodayEvent: Codable {
    let emoji: String
    let text: String
    let date: Date
    
    var description: String {
        switch text {
        case "宠物":
            return "小家伙带给妳的最大快樂就是，當妳對它裝瘋的時候，它不會取笑妳，反而會跟妳一起瘋。"
        case "学习":
            return "学习不是为了成为更好的自己，而是为了遇见更美好的人生。"
        case "工作":
            return "每一份付出都是一颗种子，终会开出属于你的花。"
        case "朋友":
            return "真挚的友情如同温暖的阳光，照亮我们的生活。"
        case "恋人":
            return "爱是生命中最美的意外，让平凡的日子都闪耀着幸福的光。"
        case "家人":
            return "家是温暖的港湾，每一刻相聚都是最珍贵的时光。"
        case "食物":
            return "美食不仅滋养身体，更能治愈心灵，让生活充满幸福的味道。"
        case "娱乐":
            return "在快乐中放松自己，让心灵找到属于自己的节奏。"
        case "运动":
            return "运动不仅让身体更健康，更让心情焕发活力。"
        case "爱好":
            return "坚持做自己喜欢的事，每一天都是一次心灵的冒险。"
        case "旅行":
            return "旅行不只是看风景，更是让心灵找到归属的过程。"
        default:
            return "今天的点滴都是明天的美好回忆。"
        }
    }
    
    static let shared = TodayEventStorage()
}

class TodayEventStorage {
    private let defaults = UserDefaults.standard
    private let storageKey = "todayEvent"
    
    func saveEvent(emoji: String, text: String) {
        let event = TodayEvent(emoji: emoji, text: text, date: Date())
        if let data = try? JSONEncoder().encode(event) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    func getLatestEvent() -> TodayEvent? {
        guard let data = defaults.data(forKey: storageKey),
              let event = try? JSONDecoder().decode(TodayEvent.self, from: data) else {
            return nil
        }
        
        // 检查是否是今天的事件
        let calendar = Calendar.current
        if calendar.isDateInToday(event.date) {
            return event
        }
        return nil
    }
    
    func clearTodayEvent() {
        defaults.removeObject(forKey: storageKey)
    }
} 