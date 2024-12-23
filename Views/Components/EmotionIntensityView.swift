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
    
    init(viewModel: EmotionViewModel) {
        self.viewModel = viewModel
        _selectedLevel = State(initialValue: viewModel.selectedIntensity)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // 选中的情绪
                VStack(spacing: 8) {
                    Text(viewModel.selectedEmotionType?.emoji ?? "")
                        .font(.system(size: 64))
                    
                    Text(viewModel.selectedEmotionType?.rawValue ?? "")
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.vertical, 20)
                
                // 强度选择器
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        IntensityButton(
                            level: level,
                            isSelected: selectedLevel == level
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedLevel = level
                                isAnimating = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isAnimating = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 100)
                
                // 描述文字
                Text(descriptions[selectedLevel - 1])
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                
                Spacer()
                
                // 下一步按钮
                Button(action: {
                    viewModel.selectedIntensity = selectedLevel
                    withAnimation {
                        viewModel.currentPage = .description
                    }
                }) {
                    Text("下一步")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
    }
}

// 强度按钮组件
struct IntensityButton: View {
    let level: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // 使用 Assets 中的图片
                Image("intensity\(level)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text("\(level)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    EmotionIntensityView(viewModel: EmotionViewModel())
} 