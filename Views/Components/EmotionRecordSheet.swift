import SwiftUI

struct EmotionRecordSheet: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.currentPage {
                case .intensity:
                    EmotionIntensityView(viewModel: viewModel)
                case .description:
                    EmotionDescriptionView(
                        viewModel: viewModel,
                        pageIndex: 2,
                        totalPages: 3,
                        showNextPage: .constant(false)
                    )
                case .factors:
                    EmotionFactorView(
                        viewModel: viewModel,
                        pageIndex: 3,
                        totalPages: 3
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        switch viewModel.currentPage {
                        case .intensity:
                            isPresented = false
                        case .description:
                            viewModel.currentPage = .intensity
                        case .factors:
                            viewModel.currentPage = .description
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("\(viewModel.currentPage.pageNumber)/3")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// 扩展 EmotionRecordPage 以获取页码
extension EmotionRecordPage {
    var pageNumber: Int {
        switch self {
        case .intensity:
            return 1
        case .description:
            return 2
        case .factors:
            return 3
        }
    }
}

#Preview {
    EmotionRecordSheet(viewModel: EmotionViewModel(), isPresented: .constant(true))
} 