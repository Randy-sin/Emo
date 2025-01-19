import SwiftUI

struct ReviewView: View {
    @StateObject private var viewModel = EmotionViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择器
                    Picker("时间范围", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 情绪变化趋势卡片
                    EmotionTrendCard(
                        title: "情绪变化趋势",
                        data: viewModel.getEmotionTrend(for: selectedTimeRange)
                    )
                    .padding(.horizontal)
                    
                    // 周情绪分布卡片
                    WeeklyEmotionCard(
                        title: "周天心情",
                        subtitle: "本周情绪强度分布"
                    )
                    .padding(.horizontal)
                    
                    // 情绪分布卡片
                    EmotionDistributionCard(
                        title: "情绪分布",
                        data: viewModel.getEmotionDistribution()
                    )
                    .padding(.horizontal)
                    
                    // 好事占比卡片
                    GoodThingsRatioCard(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("回顾")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadRecords()
            }
        }
    }
}

#Preview {
    ReviewView()
} 