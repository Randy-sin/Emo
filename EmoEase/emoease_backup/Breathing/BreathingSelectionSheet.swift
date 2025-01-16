import SwiftUI

struct BreathingSelectionSheet: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let cycles = [1, 3, 5, 10]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("选择呼吸练习次数")
                    .font(.headline)
                    .padding(.top)
                
                // 呼吸周期选择
                VStack(spacing: 15) {
                    ForEach(cycles, id: \.self) { cycle in
                        Button(action: {
                            viewModel.startBreathingSession(cycles: cycle)
                        }) {
                            HStack {
                                Text("\(cycle) 个周期")
                                    .font(.body)
                                Spacer()
                                Text("约 \(cycle * 19) 秒")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
            .padding()
        }
    }
}

#Preview {
    BreathingSelectionSheet(viewModel: EmotionViewModel())
} 