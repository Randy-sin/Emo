import SwiftUI

struct EmotionDescriptionView: View {
    @ObservedObject var viewModel: EmotionViewModel
    let pageIndex: Int
    let totalPages: Int
    @Binding var showNextPage: Bool
    
    // 选中的标签
    @State private var selectedTags: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Emoji和情绪类型
            VStack(spacing: 8) {
                Text(viewModel.selectedEmotionType?.emoji ?? "")
                    .font(.system(size: 64))
                
                Text(viewModel.selectedEmotionType?.rawValue ?? "")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 20)
            
            // 问题文字
            Text("如何描述你的心情呢？")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.primary)
                .padding(.bottom, 10)
            
            // 标签流式布局
            FlowLayout(spacing: 12) {
                ForEach(viewModel.getSuggestedTags(), id: \.self) { tag in
                    MoodTagButton(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        action: {
                            toggleTag(tag)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 下一步按钮
            Button(action: {
                viewModel.selectedTags = selectedTags
                withAnimation {
                    viewModel.currentPage = .factors
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
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
    
    private func toggleTag(_ tag: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
            } else {
                selectedTags.insert(tag)
            }
        }
    }
}

// 心情标签按钮组件
struct MoodTagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            Text(tag)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

#Preview {
    EmotionDescriptionView(
        viewModel: EmotionViewModel(),
        pageIndex: 2,
        totalPages: 4,
        showNextPage: .constant(false)
    )
} 