import SwiftUI

extension DayDiary {
    struct DayDiaryView: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack(spacing: 0) {
                // 关闭按钮
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // 主要内容
                VStack(spacing: 20) {
                    // 图片
                    Image("hellomor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                    
                    // 标题
                    Text("早安日记 · 元气满满")
                        .font(.system(size: 24, weight: .bold))
                    
                    // 描述文字
                    Text("跟随提问引导，规划今天的专注，展望今天的收获，让自己感受元气满满，让我们开始吧！")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // 开始按钮
                    NavigationLink(destination: MorningFeelingSelectionView(startTime: Date())) {
                        Text("开始")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.33, green: 0.33, blue: 0.44))
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    NavigationView {
        DayDiary.DayDiaryView()
    }
} 