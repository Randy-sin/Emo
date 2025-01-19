import SwiftUI
import UserNotifications

struct HomeView: View {
    @StateObject private var viewModel = EmotionViewModel()
    @State private var showingEmotionSheet = false
    @State private var showingNightDiary = false
    @State private var showingMorningDiary = false
    @State private var isNightDiaryCompleted = false
    @State private var showingNightCompletion = false
    @State private var showingMorningCompletion = false
    @State private var completionData: [String: Any]?
    @State private var notificationStatus = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 根据时间返回问候语
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "早上好"
        case 12..<14:
            return "中午好"
        case 14..<18:
            return "下午好"
        case 18..<23:
            return "晚上好"
        default:
            return "夜深了"
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if horizontalSizeClass == .regular {
                    // iPad布局
                    HStack(spacing: 0) {
                        // 左侧内容
                        ScrollView {
                            VStack(spacing: 20) {
                                // 周历视图
                                WeekCalendarView()
                                
                                // 情绪预警视图
                                if viewModel.checkEmotionAlert() != .normal {
                                    EmotionAlertView(
                                        alertLevel: viewModel.checkEmotionAlert(),
                                        suggestions: viewModel.getEmotionSuggestions()
                                    )
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                                
                                // 日记卡片
                                DiaryCardsView()
                                
                                // 情绪记录卡片
                                EmotionInputCard(viewModel: viewModel)
                                
                                // 历史记录卡片
                                NavigationLink(destination: HistoryView()) {
                                    StatisticsCard(viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 右侧统计视图
                        ScrollView {
                            StatisticsCard(viewModel: viewModel)
                                .padding()
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                        .background(Color(.systemGroupedBackground))
                    }
                } else {
                    // iPhone布局
                    ScrollView {
                        VStack(spacing: 20) {
                            // 周历视图
                            WeekCalendarView()
                            
                            // 情绪预警视图
                            if viewModel.checkEmotionAlert() != .normal {
                                EmotionAlertView(
                                    alertLevel: viewModel.checkEmotionAlert(),
                                    suggestions: viewModel.getEmotionSuggestions()
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // 日记卡片
                            DiaryCardsView()
                            
                            // 情绪记录卡片
                            EmotionInputCard(viewModel: viewModel)
                            
                            // 历史记录卡片
                            NavigationLink(destination: HistoryView()) {
                                StatisticsCard(viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("\(timeBasedGreeting)，欢迎回来")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !notificationStatus {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "bell.slash.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isShowingBreathingSelection) {
            BreathingCycleSelectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowingBreathingSession) {
            BreathingSessionView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingNightDiary) {
            NightDiary.NightDiaryView()
        }
        .fullScreenCover(isPresented: $showingMorningDiary) {
            DayDiary.DayDiaryView()
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
        .sheet(isPresented: $viewModel.showAIAnalysisSheet) {
            AIAnalysisView(viewModel: viewModel)
        }
        .onAppear {
            // 检查通知状态
            NotificationManager.shared.checkNotificationStatus { status in
                notificationStatus = status
            }
            
            // 检查晚安日记是否已完成
            isNightDiaryCompleted = NightCompletionRecord.shared.isCompletedToday()
            
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
            
            // 监听 Widget 跳转通知
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("OpenMorningDiary"),
                object: nil,
                queue: .main
            ) { _ in
                showingMorningDiary = true
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("OpenEmotionRecord"),
                object: nil,
                queue: .main
            ) { _ in
                viewModel.showEmotionSheet = true
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("OpenNightDiary"),
                object: nil,
                queue: .main
            ) { _ in
                showingNightDiary = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHomeView"))) { _ in
            // 重置视图状态
            isNightDiaryCompleted = false
            showingNightDiary = false
        }
        .animation(.spring(), value: viewModel.checkEmotionAlert())
    }
}

// 在现有代基础上添加卡片切换视图
struct DiaryCardsView: View {
    @State private var offset: CGFloat = 0
    @State private var currentIndex: CGFloat = 0
    @State private var showingNightDiary = false
    @State private var isNightDiaryCompleted = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var cardWidth: CGFloat {
        horizontalSizeClass == .regular ? 
            UIScreen.main.bounds.width * 0.3 : // iPad
            UIScreen.main.bounds.width - 40    // iPhone
    }
    
    private let cardSpacing: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            if horizontalSizeClass == .regular {
                // iPad布局：并排显示
                HStack(spacing: cardSpacing) {
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
            } else {
                // iPhone现有布局
                HStack(spacing: cardSpacing) {
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
                .padding(.trailing, cardWidth - 60)
                .offset(x: -offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                                let dragOffset = value.translation.width
                                let maxOffset = cardWidth + cardSpacing
                                offset = max(0, min(maxOffset, -dragOffset + (currentIndex * maxOffset)))
                            }
                        }
                        .onEnded { value in
                            let dragOffset = value.translation.width
                            let maxOffset = cardWidth + cardSpacing
                            let velocity = value.predictedEndLocation.x - value.location.x
                            
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                                if abs(dragOffset) > cardWidth * 0.2 || abs(velocity) > 100 {
                                    if (dragOffset > 0 || velocity > 100) && currentIndex > 0 {
                                        currentIndex = 0
                                        offset = 0
                                    } else if (dragOffset < 0 || velocity < -100) && currentIndex < 1 {
                                        currentIndex = 1
                                        offset = maxOffset
                                    }
                                } else {
                                    offset = currentIndex * maxOffset
                                }
                            }
                        }
                )
            }
        }
        .frame(height: 200)
        .fullScreenCover(isPresented: $showingNightDiary) {
            NightDiary.NightDiaryView()
        }
        .onAppear {
            isNightDiaryCompleted = NightCompletionRecord.shared.isCompletedToday()
        }
    }
}

#Preview {
    HomeView()
}
