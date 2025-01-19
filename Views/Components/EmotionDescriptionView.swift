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
            
            // 标签网格布局
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
            LazyVGrid(columns: columns, spacing: 16) {
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
                .font(.system(size: 15))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(red: 0.25, green: 0.25, blue: 0.35) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(.systemGray4), lineWidth: 0.5)
                        )
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 3, x: 0, y: 2)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
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