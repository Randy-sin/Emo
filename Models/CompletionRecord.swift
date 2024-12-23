import Foundation

class CompletionRecord {
    static let shared = CompletionRecord()
    private let defaults = UserDefaults.standard
    private let totalDaysKey = "totalCompletionDays"
    private let completedDatesKey = "completedDates"
    
    private init() {}
    
    func recordCompletion() {
        // 获取今天的日期字符串
        let today = formatDate(Date())
        
        // 获取已完成的日期集合
        var completedDates = getCurrentWeekCompletions()
        
        // 如果今天还没有记录，则添加
        if !completedDates.contains(today) {
            completedDates.insert(today)
            // 保存更新后的集合
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
            // 增加总天数
            let totalDays = defaults.integer(forKey: totalDaysKey)
            defaults.set(totalDays + 1, forKey: totalDaysKey)
        }
    }
    
    func clearTodayCompletion() {
        // 获取今天的日期字符串
        let today = formatDate(Date())
        
        // 获取已完成的日期集合
        var completedDates = getCurrentWeekCompletions()
        
        // 如果今天有记录，则移除
        if completedDates.contains(today) {
            completedDates.remove(today)
            // 保存更新后的集合
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
            // 减少总天数
            let totalDays = defaults.integer(forKey: totalDaysKey)
            if totalDays > 0 {
                defaults.set(totalDays - 1, forKey: totalDaysKey)
            }
        }
    }
    
    func getTotalDays() -> Int {
        return defaults.integer(forKey: totalDaysKey)
    }
    
    func getCurrentWeekCompletions() -> Set<String> {
        guard let data = defaults.data(forKey: completedDatesKey),
              let dates = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return []
        }
        
        // 只返回本周的完成记录
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        return Set(dates.filter { dateString in
            guard let date = parseDate(dateString) else { return false }
            return date >= weekStart && date < weekEnd
        })
    }
    
    func isCompletedToday() -> Bool {
        let today = formatDate(Date())
        let completedDates = getCurrentWeekCompletions()
        return completedDates.contains(today)
    }
    
    // 辅助方法：格式化日期为字符串
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // 辅助���法：解析日期字符串
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
} 