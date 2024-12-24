import SwiftUI

struct BreathingCycleSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmotionViewModel
    @State private var selectedCycles: Int = 1
    
    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.1, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            // 背景
            backgroundGradient
                .ignoresSafeArea()
            
            // 主要内容
            VStack(spacing: 30) {
                // 顶部标题
                Text("选择呼吸训练组数")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // 呼吸指导文字
                Text(viewModel.getBreathingGuide())
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // 选择器容器
                ZStack {
                    // 背景卡片
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 200)
                        .padding(.horizontal, 30)
                    
                    // Picker选择器
                    Picker("组数", selection: $selectedCycles) {
                        ForEach(1...5, id: \.self) { number in
                            Text("\(number) 组")
                                .foregroundColor(.white)
                                .tag(number)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
                .padding(.vertical, 20)
                
                // 开始按钮
                Button(action: {
                    viewModel.startBreathingSession(cycles: selectedCycles)
                    dismiss()
                }) {
                    Text("开始训练")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
            }
        }
    }
}

#Preview {
    BreathingCycleSelectionView(viewModel: EmotionViewModel())
} 
