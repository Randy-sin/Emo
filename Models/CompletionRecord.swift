import Foundation

class MorningCompletionRecord {
    static let shared = MorningCompletionRecord()
    private let defaults = UserDefaults.standard
    private let totalDaysKey = "morningTotalCompletionDays"
    private let completedDatesKey = "morningCompletedDates"
    
    private init() {}
    
    func recordCompletion() {
        let today = formatDate(Date())
        var completedDates = getCurrentWeekCompletions()
        
        if !completedDates.contains(today) {
            completedDates.insert(today)
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
            let totalDays = defaults.integer(forKey: totalDaysKey)
            defaults.set(totalDays + 1, forKey: totalDaysKey)
        }
    }
    
    func clearTodayCompletion() {
        let today = formatDate(Date())
        var completedDates = getCurrentWeekCompletions()
        
        if completedDates.contains(today) {
            completedDates.remove(today)
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

class NightCompletionRecord {
    static let shared = NightCompletionRecord()
    private let defaults = UserDefaults.standard
    private let totalDaysKey = "nightTotalCompletionDays"
    private let completedDatesKey = "nightCompletedDates"
    
    private init() {}
    
    func recordCompletion() {
        let today = formatDate(Date())
        var completedDates = getCurrentWeekCompletions()
        
        if !completedDates.contains(today) {
            completedDates.insert(today)
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
            let totalDays = defaults.integer(forKey: totalDaysKey)
            defaults.set(totalDays + 1, forKey: totalDaysKey)
        }
    }
    
    func clearTodayCompletion() {
        let today = formatDate(Date())
        var completedDates = getCurrentWeekCompletions()
        
        if completedDates.contains(today) {
            completedDates.remove(today)
            if let data = try? JSONEncoder().encode(completedDates) {
                defaults.set(data, forKey: completedDatesKey)
            }
            
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
} 