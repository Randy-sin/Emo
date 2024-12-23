import SwiftUI

struct EmotionGridView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @State private var showIntensitySheet = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(EmotionType.allCases, id: \.self) { emotion in
                EmotionButton(
                    emotion: emotion,
                    isSelected: viewModel.selectedEmotionType == emotion
                ) {
                    viewModel.selectedEmotionType = emotion
                    viewModel.currentPage = .intensity
                    viewModel.showEmotionSheet = true
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .fullScreenCover(isPresented: $viewModel.showEmotionSheet) {
            EmotionRecordSheet(viewModel: viewModel, isPresented: $viewModel.showEmotionSheet)
        }
    }
}

// 情绪按钮组件
struct EmotionButton: View {
    let emotion: EmotionType
    let isSelected: Bool
    let action: () -> Void
    
    // 添加动画状态
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.1
            }
            
            // 短暂延迟后恢复原始大小
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    // 背景层
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? 
                            emotion.backgroundColor.opacity(0.3) : 
                            emotion.backgroundColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    // 表情文字
                    Text(emotion.emoji)
                        .font(.system(size: 24))
                }
                .scaleEffect(scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(emotion.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
    }
}

// 扩展EmotionType添加UI相关属性
extension EmotionType {
    var backgroundColor: Color {
        switch self {
        case .happy: return Color(red: 0.4, green: 0.8, blue: 0.4) // 明快的绿色
        case .calm: return Color(red: 0.6, green: 0.8, blue: 1.0)  // 柔和的蓝色
        case .anxious: return Color(red: 0.8, green: 0.4, blue: 0.8) // 紫色
        case .stress: return Color(red: 0.7, green: 0.7, blue: 0.7) // 中性灰
        case .angry: return Color(red: 1.0, green: 0.4, blue: 0.4) // 鲜艳的红色
        case .breathing: return Color(red: 1.0, green: 0.8, blue: 0.4) // 温暖的黄色
        case .closing: return Color(red: 0.4, green: 0.8, blue: 0.8) // 清新的薄荷色
        case .inhalation: return Color(red: 1.0, green: 0.6, blue: 0.4) // 橙色
        case .inflation: return Color(red: 0.4, green: 0.6, blue: 1.0) // 亮蓝色
        case .joyful: return Color(red: 1.0, green: 0.8, blue: 0.8) // 粉色
        case .pardons: return Color(red: 0.8, green: 0.6, blue: 1.0) // 淡紫色
        case .rhythms: return Color(red: 0.6, green: 0.8, blue: 0.8) // 浅蓝绿色
        case .tired: return Color(red: 0.6, green: 0.6, blue: 0.7) // 暗灰紫色 - 表达疲惫感
        case .etc: return Color(red: 0.6, green: 0.6, blue: 0.6) // 中性灰
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .stress: return "😐"
        case .angry: return "😠"
        case .breathing: return "😮‍💨"
        case .closing: return "😌"
        case .inhalation: return "🫁"
        case .inflation: return "😤"
        case .joyful: return "🥳"
        case .pardons: return "🤝"
        case .rhythms: return "🎵"
        case .tired: return "😩" // 疲惫表情
        case .etc: return "🤔"
        }
    }
}

#Preview {
    EmotionGridView(viewModel: EmotionViewModel())
        .padding()
        .background(Color(.systemGroupedBackground))
} 