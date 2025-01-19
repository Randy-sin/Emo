import SwiftUI

struct WeeklyStatsCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    // 统计数据
    @State private var diaryCount: Int = 0
    @State private var mindfulMinutes: Int = 0
    @State private var totalGoodThings: Int = 0
    @State private var totalFocus: Int = 0
    @State private var weeklyCompletions: [Bool] = Array(repeating: false, count: 7)
    
    // 获取本周日期范围
    private var weekDateRange: String {
        let calendar = Calendar.current
        let today = Date()
        
        // 获取本周的开始和结束日期
        let weekday = calendar.component(.weekday, from: today)
        let weekStart = calendar.date(byAdding: .day, value: 1-weekday, to: today)!
        let weekEnd = calendar.date(byAdding: .day, value: 7-weekday, to: today)!
        
        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d"
        
        return "\(formatter.string(from: weekStart)) ~ \(formatter.string(from: weekEnd))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题栏
            HStack {
                Label {
                    Text("本周回顾")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                } icon: {
                    Image("review")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                Text(weekDateRange)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            // 统计数字
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatBox(title: "日记数量", value: "\(diaryCount)", unit: "篇", 
                       customImage: "Journal", color: .blue)
                StatBox(title: "正念时长", value: "\(mindfulMinutes)", unit: "分钟", 
                       customImage: "Clock", color: .purple)
                StatBox(title: "累计好事", value: "\(totalGoodThings)", unit: "件", 
                       customImage: "Hearts", color: .pink)
                StatBox(title: "累计专注", value: "\(totalFocus)", unit: "次", 
                       customImage: "Square Border", color: .orange)
            }
            
            // 好事发生一整周
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("好事发生一整周")
                        .font(.system(size: 17, weight: .medium))
                } icon: {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.pink)
                }
                
                HStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 4) {
                            Image("sun")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .opacity(weeklyCompletions[index] ? 1 : 0.3)
                            
                            Text(["日","一","二","三","四","五","六"][index])
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text("= 和上周一样多")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 5)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                       radius: 15, x: 0, y: 5)
        )
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        // 获取日记数量
        diaryCount = DayDiaryRecord.shared.getAllRecords().count + NightDiaryRecord.shared.getAllRecords().count
        
        // 获取正念时长（从呼吸记录中计算）
        if let data = UserDefaults.standard.data(forKey: "breathingRecords"),
           let records = try? JSONDecoder().decode([BreathingRecord].self, from: data) {
            // 计算所有呼吸练习的总时长（分钟）
            mindfulMinutes = Int(records.reduce(0) { $0 + $1.duration } / 60)
            // 更新累计专注次数
            totalFocus = records.count
        } else {
            mindfulMinutes = 0
            totalFocus = 0
        }
        
        // 获取累计好事
        totalGoodThings = MorningCompletionRecord.shared.getTotalDays()
        
        // 获取一周好事完成情况
        let completedDates = MorningCompletionRecord.shared.getCurrentWeekCompletions()
        var weeklyStatus = Array(repeating: false, count: 7)
        
        let calendar = Calendar.current
        let today = Date()
        
        // 遍历最近7天
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateString = formatter.string(from: date)
                let weekday = calendar.component(.weekday, from: date) - 1 // 0 = Sunday
                weeklyStatus[weekday] = completedDates.contains(dateString)
            }
        }
        
        weeklyCompletions = weeklyStatus
    }
}

// 统计数字盒子组件
struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let customImage: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            } icon: {
                Image(customImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(color)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    WeeklyStatsCard()
        .padding()
        .background(Color(.systemGroupedBackground))
} 