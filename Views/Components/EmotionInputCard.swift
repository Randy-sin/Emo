import SwiftUI

struct EmotionInputCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 标题
            HStack {
                HStack(spacing: 6) {
                    Image("heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d.height * 0.75
                        }
                    Text("记录情绪")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // 情绪网格
            EmotionGridView(viewModel: viewModel)
            
            // 快捷操作
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.showQuickRecordSheet = true
                }) {
                    Label("快速记录", systemImage: "bolt.fill")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.showAIAnalysisSheet = true
                }) {
                    Label("AI 分析", systemImage: "brain.head.profile")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $viewModel.showEmotionSheet) {
            EmotionRecordSheet(viewModel: viewModel, isPresented: $viewModel.showEmotionSheet)
        }
        .sheet(isPresented: $viewModel.showQuickRecordSheet) {
            QuickRecordView(viewModel: viewModel)
        }
    }
}

#Preview {
    EmotionInputCard(viewModel: EmotionViewModel())
        .padding()
        .background(Color(.systemGroupedBackground))
} 