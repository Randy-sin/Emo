import SwiftUI

extension NightDiary {
    struct NightReviewCard: View {
        @Binding var isCompleted: Bool
        @State private var showingNightDiary = false
        @State private var showingPreview = false
        @State private var todayEvent: TodayEvent?
        @State private var currentRecord: NightDiaryRecord.Record?
        
        // 花朵视图组件
        private struct FlowerView: View {
            var body: some View {
                ZStack {
                    // 花瓣
                    ForEach(0..<4) { index in
                        Circle()
                            .frame(width: 12, height: 12)
                            .offset(
                                x: 8 * cos(Double(index) * .pi / 2),
                                y: 8 * sin(Double(index) * .pi / 2)
                            )
                    }
                    // 花蕊
                    Circle()
                        .frame(width: 8, height: 8)
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        
        var body: some View {
            ZStack {
                // 背景图片
                Image("night")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                // 渐变遮罩层
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 内容容器
                VStack {
                    Spacer()
                        .frame(height: 30)
                    
                    // 主要内容
                    VStack(spacing: isCompleted ? 16 : 12) {
                        // 今日好事标题
                        Text("今日好事")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 8)
                        
                        if let event = todayEvent {
                            // 显示用户选择的事件
                            if isCompleted {
                                // 完成日记后显示带花朵装饰的版本
                                HStack(spacing: 16) {
                                    FlowerView()
                                    Text("\(event.emoji) \(event.text)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                        .multilineTextAlignment(.center)
                                    FlowerView()
                                }
                                .padding(.top, 4)
                            } else {
                                // 未完成日记时的普通显示
                                Text("\(event.emoji) \(event.text)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Divider()
                                .frame(width: 200)
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, isCompleted ? 16 : 12)
                            
                            // 描述性文字
                            Text(event.description)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 20)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        } else {
                            // 默认显示
                            Text("晚安好事发生")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .multilineTextAlignment(.center)
                            
                            Text("发现今天的小确幸")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .multilineTextAlignment(.center)
                            
                            // 只在未完成日记且没有今日事件时显示按钮
                            Button(action: {
                                showingNightDiary = true
                            }) {
                                Text("开始")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.purple)
                                    .frame(width: 120, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .frame(height: 200)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .onTapGesture {
                if isCompleted && todayEvent != nil {
                    showingPreview = true
                } else if !isCompleted {
                    showingNightDiary = true
                }
            }
            .fullScreenCover(isPresented: $showingNightDiary) {
                NightDiaryView()
            }
            .sheet(isPresented: $showingPreview) {
                NavigationView {
                    NightDiaryPreview(record: NightDiaryRecord.shared.getCurrentRecord())
                }
            }
            .onAppear {
                // 检查完成状态和今日事件
                isCompleted = CompletionRecord.shared.isCompletedToday()
                todayEvent = TodayEvent.shared.getLatestEvent()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHomeView"))) { _ in
                showingNightDiary = false
                isCompleted = CompletionRecord.shared.isCompletedToday()
                todayEvent = TodayEvent.shared.getLatestEvent()
            }
        }
    }
}

#Preview {
    NightDiary.NightReviewCard(isCompleted: .constant(false))
        .padding()
        .background(Color(.systemGroupedBackground))
} 