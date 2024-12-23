import SwiftUI

struct EmotionRecordFlow: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmotionViewModel
    @State private var showFactorView = false
    
    var body: some View {
        ZStack {
            // 第一页：情绪描述
            EmotionDescriptionView(
                viewModel: viewModel,
                pageIndex: 1,
                totalPages: 2,
                showNextPage: $showFactorView
            )
            .opacity(showFactorView ? 0 : 1)
            
            // 第二页：影响因素
            if showFactorView {
                EmotionFactorView(
                    viewModel: viewModel,
                    pageIndex: 2,
                    totalPages: 2
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showFactorView)
    }
}

#Preview {
    EmotionRecordFlow(viewModel: EmotionViewModel())
} 