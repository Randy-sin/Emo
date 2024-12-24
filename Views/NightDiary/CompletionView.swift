import SwiftUI

extension NightDiary {
    struct CompletionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        let feeling: Int
        let events: [String]
        let eventDescription: String
        let futureExpectation: String
        
        // 获取本周的日期数组
        private var weekDays: [Date] {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let dayOfWeek = calendar.component(.weekday, from: today)
            let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
            
            return (weekdays.lowerBound ..< weekdays.upperBound).map { day in
                calendar.date(byAdding: .day,
                            value: day - dayOfWeek,
                            to: today)!
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("5/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 标题
                Text("🌙 晚安好梦 🌙")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 60)
                
                // 主要图标
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.purple)
                    .padding(.top, 40)
                
                // 第一天文本
                Text("第1天")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.93, green: 0.87, blue: 0.83))
                    .padding(.top, 20)
                
                // 本周好眠
                VStack(spacing: 12) {
                    Text("本周好眠")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                    
                    // 星期显示
                    HStack(spacing: 20) {
                        ForEach(weekDays, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let weekday = Calendar.current.component(.weekday, from: date)
                            let weekdayString = ["日", "一", "二", "三", "四", "五", "六"][weekday - 1]
                            
                            VStack(spacing: 8) {
                                Text(weekdayString)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "moon.stars.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(isToday ? .purple : .gray.opacity(0.3))
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 晚安按钮
                Button(action: {
                    // 保存日记记录
                    NightDiaryRecord.shared.saveRecord(
                        startTime: startTime,
                        feeling: feeling,
                        events: events,
                        eventDescription: eventDescription,
                        futureExpectation: futureExpectation
                    )
                    
                    // 发送通知以关闭所有页面
                    NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
                    
                    // 延迟一小段时间后发送重置通知，确保视图已经关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ResetHomeView"),
                            object: nil
                        )
                    }
                    
                    // 关闭当前视图
                    dismiss()
                }) {
                    Text("晚安")
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
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 17, weight: .medium))
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        NightDiary.CompletionView(
            startTime: Date(),
            feeling: 3,
            events: ["运动", "学习"],
            eventDescription: "今天运动很开心",
            futureExpectation: "希望明天也能保持好心情"
        )
    }
} 