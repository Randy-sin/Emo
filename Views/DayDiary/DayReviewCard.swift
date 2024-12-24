import SwiftUI
import Combine

extension DayDiary {
    struct DayReviewCard: View {
        // 使用 StateObject 来管理状态，避免频繁重建
        @StateObject private var viewModel = DayReviewViewModel()
        @State private var showingDayDiary = false
        @State private var showingPreview = false
        
        // 预设的事件选项
        private let predefinedEvents = [
            ("📚", "学习"),
            ("💼", "工作"),
            ("❤️", "朋友"),
            ("💝", "恋人"),
            ("🏠", "家人"),
            ("🍜", "食物"),
            ("🎡", "娱乐"),
            ("🏃", "运动"),
            ("💖", "爱好"),
            ("🌏", "旅行"),
            ("🐶", "宠物")
        ]
        
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
                Image("morning")
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
                    VStack(spacing: viewModel.isDiaryCompleted ? 16 : 12) {
                        // 今日好事标题
                        Text("今日好事")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 8)
                        
                        if viewModel.isDiaryCompleted, let record = viewModel.currentRecord {
                            // 完成日记后显示带花朵装饰的版本
                            HStack(spacing: 16) {
                                FlowerView()
                                if let firstEvent = record.events.first {
                                    // 获取事件对应的emoji
                                    let emoji = predefinedEvents.first { $0.1 == firstEvent }?.0 ?? ""
                                    Text("\(emoji) \(firstEvent)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                        .multilineTextAlignment(.center)
                                }
                                FlowerView()
                            }
                            .padding(.top, 4)
                            
                            Divider()
                                .frame(width: 200)
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, viewModel.isDiaryCompleted ? 16 : 12)
                            
                            // 描述性文字
                            if let firstEvent = record.events.first {
                                let prompt = MorningEventsPrompts.getPrompt(for: firstEvent)
                                Text(prompt.descriptionPrompt)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 20)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                        } else {
                            // 默认显示
                            Text("早安元气满满")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .multilineTextAlignment(.center)
                            
                            Text("开启元气满满的一天")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .multilineTextAlignment(.center)
                            
                            // 只在未完成日记时显示按钮
                            Button(action: {
                                showingDayDiary = true
                            }) {
                                Text("开始")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.orange)
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
                if viewModel.isDiaryCompleted, viewModel.currentRecord != nil {
                    showingPreview = true
                } else if !viewModel.isDiaryCompleted {
                    showingDayDiary = true
                }
            }
            .fullScreenCover(isPresented: $showingDayDiary) {
                NavigationView {
                    DayDiaryView()
                }
            }
            .sheet(isPresented: $showingPreview) {
                NavigationView {
                    DayDiaryPreview(record: viewModel.currentRecord)
                }
            }
            .onAppear {
                viewModel.updateState()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHomeView")).receive(on: DispatchQueue.main)) { _ in
                showingDayDiary = false
                showingPreview = false
                viewModel.updateState()
            }
        }
    }
}

// ViewModel to manage state
class DayReviewViewModel: ObservableObject {
    @Published private(set) var isDiaryCompleted: Bool
    @Published private(set) var currentRecord: DayDiaryRecord.Record?
    
    init() {
        self.isDiaryCompleted = false
        self.currentRecord = nil
        self.updateState()
    }
    
    func updateState() {
        // 直接在主线程更新状态，因为这些操作都是简单的内存操作
        isDiaryCompleted = MorningCompletionRecord.shared.isCompletedToday()
        currentRecord = DayDiaryRecord.shared.getCurrentRecord()
    }
}

#Preview {
    DayDiary.DayReviewCard()
        .padding()
} 