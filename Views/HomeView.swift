import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = EmotionViewModel()
    @State private var showingEmotionSheet = false
    @State private var showingNightDiary = false
    @State private var isNightDiaryCompleted = false
    @State private var showingNightCompletion = false
    @State private var showingMorningCompletion = false
    @State private var completionData: [String: Any]?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 日记卡片
                    DiaryCardsView()
                    
                    // 情绪记录卡片
                    EmotionInputCard(viewModel: viewModel)
                    
                    // 历史记录卡片
                    NavigationLink(destination: HistoryView()) {
                        StatisticsCard(viewModel: viewModel)
                    }
                    
                    // 情绪概览
                    EmotionOverviewView(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("心情日记")
            .sheet(isPresented: $viewModel.isShowingBreathingSelection) {
                BreathingCycleSelectionView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingBreathingSession) {
                BreathingSessionView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showingNightDiary) {
                NightDiary.NightDiaryView()
            }
            .fullScreenCover(isPresented: $showingNightCompletion) {
                if let data = completionData {
                    NightDiary.CompletionView(
                        startTime: data["startTime"] as! Date,
                        feeling: data["feeling"] as! Int,
                        events: data["events"] as! [String],
                        eventDescription: data["eventDescription"] as! String,
                        futureExpectation: data["futureExpectation"] as! String
                    )
                }
            }
            .fullScreenCover(isPresented: $showingMorningCompletion) {
                if let data = completionData {
                    DayDiary.MorningCompletionView(
                        startTime: data["startTime"] as! Date,
                        feeling: data["feeling"] as! Int,
                        events: data["events"] as! [String],
                        eventDescription: data["eventDescription"] as! String,
                        futureExpectation: data["futureExpectation"] as! String
                    )
                }
            }
        }
        .onAppear {
            // 检查晚安日记是否已完成
            isNightDiaryCompleted = CompletionRecord.shared.isCompletedToday()
            
            // 监听晚安日记完成通知
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowNightCompletion"),
                object: nil,
                queue: .main
            ) { notification in
                if let userInfo = notification.userInfo as? [String: Any] {
                    completionData = userInfo
                    showingNightCompletion = true
                }
            }
            
            // 监听早安日记完成通知
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowMorningCompletion"),
                object: nil,
                queue: .main
            ) { notification in
                if let userInfo = notification.userInfo as? [String: Any] {
                    completionData = userInfo
                    showingMorningCompletion = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHomeView"))) { _ in
            // 重置视图状态
            isNightDiaryCompleted = false
            showingNightDiary = false
        }
    }
}

// 情绪概览视图
struct EmotionOverviewView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @State private var cachedStats: EmotionStats?
    
    var body: some View {
        VStack(spacing: 15) {
            // 标题栏
            HStack {
                Text("情绪回顾")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.gray)
                }
            }
            
            // 统计数据
            if let stats = viewModel.emotionStats {
                StatisticsContent(stats: stats)
            } else {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

// 在现有代基础上添加卡片切换视图
struct DiaryCardsView: View {
    @State private var offset: CGFloat = 0
    @State private var currentIndex: CGFloat = 0
    @State private var showingNightDiary = false
    @State private var isNightDiaryCompleted = false
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 40 
    private let cardSpacing: CGFloat = 20 
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: cardSpacing) {  // 恢复卡片间距
                // 早安日记卡片
                DayDiary.DayReviewCard()
                    .frame(width: cardWidth)
                
                // 晚安日记卡片
                NightDiary.NightReviewCard(isCompleted: $isNightDiaryCompleted)
                    .onTapGesture {
                        if !isNightDiaryCompleted {
                            showingNightDiary = true
                        }
                    }
                    .frame(width: cardWidth)
            }
            .padding(.trailing, cardWidth - 60)  // 控制右侧卡片露出的宽度
            .offset(x: -offset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                            // 限制拖动范围
                            let dragOffset = value.translation.width
                            let maxOffset = cardWidth + cardSpacing
                            offset = max(0, min(maxOffset, -dragOffset + (currentIndex * maxOffset)))
                        }
                    }
                    .onEnded { value in
                        let dragOffset = value.translation.width
                        let maxOffset = cardWidth + cardSpacing
                        let velocity = value.predictedEndLocation.x - value.location.x
                        
                        // 判断滑动方向和距离，考虑滑动速度
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                            if abs(dragOffset) > cardWidth * 0.2 || abs(velocity) > 100 {
                                if (dragOffset > 0 || velocity > 100) && currentIndex > 0 {
                                    // 向右滑动，回早安日记
                                    currentIndex = 0
                                    offset = 0
                                } else if (dragOffset < 0 || velocity < -100) && currentIndex < 1 {
                                    // 向左滑动，切换到晚安日记
                                    currentIndex = 1
                                    offset = maxOffset
                                }
                            } else {
                                // 回弹到原位
                                offset = currentIndex * maxOffset
                            }
                        }
                    }
            )
        }
        .frame(height: 200)
        .fullScreenCover(isPresented: $showingNightDiary) {
            NightDiary.NightDiaryView()
        }
        .onAppear {
            isNightDiaryCompleted = CompletionRecord.shared.isCompletedToday()
        }
    }
}

#Preview {
    HomeView()
}
