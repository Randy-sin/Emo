import SwiftUI

extension DayDiary {
    struct MorningCompletionView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.presentationMode) private var presentationMode
        @State private var totalDays: Int = 0
        @State private var completedDates: Set<String> = []
        
        let startTime: Date
        let feeling: Int
        let events: [String]
        let eventDescription: String
        let futureExpectation: String
        
        // 获取当前是第几天
        private var currentDay: Int {
            return totalDays
        }
        
        // 获取当前是星期几（0是周日，1是周一，依此类推）
        private var currentWeekday: Int {
            let calendar = Calendar.current
            return calendar.component(.weekday, from: Date()) - 1
        }
        
        // 检查某天是否完成
        private func isDayCompleted(_ weekday: Int) -> Bool {
            let calendar = Calendar.current
            let today = Date()
            guard let date = calendar.date(byAdding: .day, value: weekday - currentWeekday, to: today) else {
                return false
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return completedDates.contains(formatter.string(from: date))
        }
        
        // 太阳形状组件
        private struct SunShape: View {
            let size: CGFloat
            let color: Color
            
            var body: some View {
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(color)
            }
        }
        
        var body: some View {
            VStack {
                // 标题
                Text("🌞元气满满🌞")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 40)
                
                // 中间的大太阳和天数
                ZStack {
                    SunShape(size: 200, color: .yellow)
                    Text("第\(currentDay)天")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 60)
                
                // 周进度视图
                VStack(spacing: 16) {
                    Text("本周元气满满")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                    
                    // 星期指示器
                    HStack(spacing: 12) {
                        ForEach(0..<7) { index in
                            VStack(spacing: 8) {
                                // 太阳指示器
                                SunShape(
                                    size: 36,
                                    color: isDayCompleted(index) ? .yellow : Color(.systemGray5)
                                )
                                
                                // 星期文字
                                Text(["日", "一", "二", "三", "四", "五", "六"][index])
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 分界线
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray5))
                    .padding(.horizontal, 20)
                
                // 鼓励文字
                Text("今天也要元气满满哦！")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
                
                // 完成按钮
                Button(action: {
                    // 保存日记记录
                    DayDiaryRecord.shared.saveRecord(
                        startTime: startTime,
                        feeling: feeling,
                        events: events,
                        eventDescription: eventDescription,
                        futureExpectation: futureExpectation
                    )
                    
                    // 发送通知更新主页
                    NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
                    // 延迟一小段时间后发送重置通知，确保视图已经关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(name: NSNotification.Name("ResetHomeView"), object: nil)
                    }
                    // 关闭所有页面，返回到根视图
                    dismiss()
                }) {
                    Text("我真棒")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.33, green: 0.33, blue: 0.44))
                        .cornerRadius(27)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarBackButtonHidden(true)
            .onAppear {
                totalDays = CompletionRecord.shared.getTotalDays()
                completedDates = CompletionRecord.shared.getCurrentWeekCompletions()
            }
        }
    }
}

#Preview {
    NavigationView {
        DayDiary.MorningCompletionView(
            startTime: Date(),
            feeling: 3,
            events: ["运动", "学习"],
            eventDescription: "今天想要好好运动，保持健康",
            futureExpectation: "希望能完成所有计划的事情"
        )
    }
} 