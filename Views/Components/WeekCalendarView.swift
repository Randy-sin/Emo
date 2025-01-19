import SwiftUI

struct WeekCalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let calendar = Calendar.current
    private let weekDays = ["日", "一", "二", "三", "四", "五", "六"]
    @State private var weekDates: [Date] = []
    
    init() {
        // 初始化一周的日期
        _weekDates = State(initialValue: generateWeekDates())
    }
    
    private func generateWeekDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current
        
        // 获取本周日的日期
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 1 // 1 代表周日
        
        guard let sunday = calendar.date(from: components) else { return [] }
        
        // 生成一周的日期
        return (0...6).map { day in
            calendar.date(byAdding: .day, value: day, to: sunday) ?? today
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.element) { index, date in
                VStack(spacing: 4) {
                    // 星期文字
                    Text(weekDays[index])
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    // 日期数字
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 16, weight: isToday(date) ? .medium : .regular))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isToday(date) ? 
                                    (colorScheme == .dark ? Color.white.opacity(0.2) : Color.white) : 
                                    Color.clear)
                                .shadow(color: isToday(date) ? Color.black.opacity(0.1) : .clear,
                                       radius: 4, x: 0, y: 2)
                        )
                        .foregroundColor(isToday(date) ? 
                            (colorScheme == .dark ? .white : .primary) : 
                            .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? 
                    Color(.systemGray6) : 
                    Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05),
                       radius: 8, x: 0, y: 4)
        )
    }
} 