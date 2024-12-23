import SwiftUI

struct StatisticsCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 标题
            HStack {
                Label("统计概览", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            if let stats = viewModel.emotionStats {
                // 使用现有的StatisticsContent
                StatisticsContent(stats: stats)
            } else {
                // 无数据状态
                HStack {
                    Spacer()
                    Text("暂无数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    StatisticsCard(viewModel: EmotionViewModel())
        .padding()
        .background(Color(.systemBackground))
} 