import SwiftUI

struct QuickRecordView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 最近使用的情绪
                    if !viewModel.recentEmotions.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("最近记录")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.recentEmotions, id: \.timestamp) { emotion in
                                RecentEmotionCard(emotion: emotion) {
                                    // 快速记录这个情绪
                                    viewModel.quickRecord(emotion)
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    // 根据时间推荐
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推荐记录")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.getRecommendedEmotions(), id: \.rawValue) { type in
                            RecommendedEmotionCard(type: type) {
                                viewModel.quickRecordRecommended(type)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("快速记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 最近情绪卡片
struct RecentEmotionCard: View {
    let emotion: EmotionStorage.RecentEmotion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(emotion.type.emoji)
                            .font(.title2)
                        Text(emotion.type.description)
                            .font(.headline)
                    }
                    
                    // 标签流
                    FlowLayout(spacing: 8) {
                        ForEach(Array(emotion.tags.prefix(3)), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }
                }
                
                Spacer()
                
                // 情绪强度
                Text("强度: \(emotion.intensity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

// 推荐情绪卡片
struct RecommendedEmotionCard: View {
    let type: EmotionType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(type.emoji)
                    .font(.title2)
                Text(type.description)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#Preview {
    QuickRecordView(viewModel: EmotionViewModel())
} 