import SwiftUI

struct EmotionIntensityView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @State private var selectedLevel: Int
    @State private var isAnimating = false
    
    private let descriptions = [
        "几乎感觉不到",
        "有一点感觉",
        "明显感受到",
        "感受强烈",
        "感受非常强烈"
    ]
    
    // 定义每个等级对应的颜色和文字
    private let levelInfo: [Int: (Color, String)] = [
        1: (Color(red: 0.8, green: 0.4, blue: 0.9), "一点点"),  // 紫色
        2: (Color(red: 0.4, green: 0.6, blue: 0.9), "比较"),    // 蓝色
        3: (Color(red: 0.4, green: 0.9, blue: 0.6), "适中"),    // 绿色
        4: (Color(red: 1.0, green: 0.8, blue: 0.3), "很"),      // 黄色
        5: (Color(red: 1.0, green: 0.6, blue: 0.3), "非常")   // 橙色
    ]
    
    // 获取当前选择等级的背景颜色
    private var currentBackgroundColor: Color {
        levelInfo[selectedLevel]?.0 ?? .white
    }
    
    // 获取简略的情绪描述
    private var shortEmotionName: String {
        guard let emotionType = viewModel.selectedEmotionType else { return "心情" }
        switch emotionType {
        case .happy, .joyful: return "开心"
        case .calm: return "平静"
        case .anxious: return "焦虑"
        case .stress: return "压力"
        case .angry: return "生气"
        case .tired: return "疲惫"
        default: return emotionType.rawValue
        }
    }
    
    init(viewModel: EmotionViewModel) {
        self.viewModel = viewModel
        _selectedLevel = State(initialValue: viewModel.selectedIntensity)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                currentBackgroundColor.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: selectedLevel)
                
                VStack(spacing: 20) {
                    // 页面标题
                    Text("现在\(shortEmotionName)的程度多高?")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 60)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // 大表情显示
                    Image("intensity\(selectedLevel)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .transition(.opacity)
                    
                    Spacer()
                    
                    // 底部表情选择器
                    HStack(spacing: 20) {
                        ForEach(1...5, id: \.self) { level in
                            VStack(spacing: 8) {
                                Button(action: {
                                    withAnimation {
                                        selectedLevel = level
                                    }
                                }) {
                                    Image("intensity\(level)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                        .opacity(selectedLevel == level ? 1 : 0.5)
                                }
                                
                                Text(levelInfo[level]?.1 ?? "")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // 下一步按钮
                    Button(action: {
                        viewModel.selectedIntensity = selectedLevel
                        withAnimation {
                            viewModel.currentPage = .description
                        }
                    }) {
                        Text("下一步")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.25, green: 0.25, blue: 0.35))
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EmotionIntensityView(viewModel: EmotionViewModel())
} 