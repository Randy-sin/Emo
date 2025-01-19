import SwiftUI

// 创建一个全局单例实例
let globalPracticeStats = PracticeStatsService.shared

struct QuestionView: View {
    @Environment(\.dismiss) private var dismiss
    let question: String
    let pageIndex: Int
    @Binding var rootIsPresented: Bool
    @Binding var showCompletion: Bool
    @State private var answer = ""
    @State private var showNextQuestion = false
    @State private var previousCharCount = 0
    @FocusState private var isFocused: Bool
    
    // 使用 EnvironmentObject 共享统计数据
    @EnvironmentObject private var stats: ThemeStats
    @EnvironmentObject private var practiceStats: PracticeStatsService
    
    let themeType: ThemeType
    
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.black.opacity(0.75))
                    }
                    
                    Spacer()
                    
                    Text("\(pageIndex + 1)/5")
                        .font(.system(size: 17))
                        .foregroundColor(.black.opacity(0.75))
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 问题文本
                Text(question)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.black.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 32)
                
                Spacer()
                
                // 输入框
                TextField("", text: $answer, axis: .vertical)
                    .font(.system(size: 17))
                    .foregroundColor(.black.opacity(0.9))
                    .focused($isFocused)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .onChange(of: answer) { oldValue, newValue in
                        // 计算新增的字数
                        let currentCount = newValue.count
                        let addedCount = currentCount - previousCharCount
                        if addedCount > 0 {  // 只在增加字数时累加
                            stats.addCharacterCount(addedCount)
                        }
                        previousCharCount = currentCount
                    }
                
                // 下一步按钮
                if pageIndex < 4 {
                    Button(action: {
                        showNextQuestion = true
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color(red: 0.25, green: 0.25, blue: 0.35))
                            )
                    }
                    .padding(.bottom, 30)
                } else {
                    Button(action: {
                        if pageIndex == 4 {
                            practiceStats.incrementPracticeCount()
                            showCompletion = true
                        }
                    }) {
                        Text("完成")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 0.25, green: 0.25, blue: 0.35))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showNextQuestion) {
            if pageIndex < 4 {
                QuestionView(
                    question: themeType.questions[pageIndex + 1],
                    pageIndex: pageIndex + 1,
                    rootIsPresented: $rootIsPresented,
                    showCompletion: $showCompletion,
                    themeType: themeType
                )
                .environmentObject(stats)
                .environmentObject(practiceStats)
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            ThemeCompletionView(
                isPresented: $rootIsPresented,
                themeName: themeType.title,
                mindfulnessTime: stats.totalTime,
                characterCount: stats.totalCharacterCount,
                practiceCount: practiceStats.practiceCount
            )
        }
        .onAppear {
            stats.startTracking()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isFocused = true
            }
        }
        .onDisappear {
            // 更新字数统计
            stats.addCharacterCount(answer.count)
        }
    }
}

// 用于跨视图共享统计数据
class ThemeStats: ObservableObject {
    @Published var totalTime: TimeInterval = 0  // 总时长(秒)
    @Published var totalCharacterCount: Int = 0  // 总字数
    private var startTime: Date?  // 开始时间
    
    // 开始计时
    func startTracking() {
        startTime = Date()
        print("Started tracking at: \(startTime!)")
    }
    
    // 结束计时并更新时长(转换为分钟)
    func stopTracking() {
        guard let start = startTime else { return }
        let timeSpent = Date().timeIntervalSince(start)
        totalTime = timeSpent / 60  // 转换为分钟
        print("Stopped tracking. Total time in minutes: \(totalTime)")
    }
    
    // 累加字数
    func addCharacterCount(_ count: Int) {
        totalCharacterCount += count
        print("Added \(count) characters. Total: \(totalCharacterCount)")
    }
    
    // 重置所有数据
    func reset() {
        totalTime = 0
        totalCharacterCount = 0
        startTime = nil
    }
}

#Preview {
    QuestionView(
        question: ThemeType.selfLove.questions[0],
        pageIndex: 0,
        rootIsPresented: .constant(true),
        showCompletion: .constant(false),
        themeType: .selfLove
    )
    .environmentObject(ThemeStats())
    .environmentObject(globalPracticeStats)
} 