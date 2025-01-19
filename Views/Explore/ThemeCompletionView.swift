import SwiftUI

struct ThemeCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    let themeName: String
    let mindfulnessTime: TimeInterval
    let characterCount: Int
    let practiceCount: Int
    
    // 格式化正念时长
    private var formattedTime: String {
        let minutes = Int(mindfulnessTime / 60)
        let seconds = Int(mindfulnessTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%.1f", Double(minutes) + Double(seconds) / 60)
    }
    
    // 格式化正念字数
    private var formattedCharacterCount: String {
        return "\(characterCount)"
    }
    
    // 格式化练习次数
    private var formattedPracticeCount: String {
        return "\(practiceCount)次"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 完成图标
            Image("ThemeCheckmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.top, 120)
            
            // 完成标题
            Text("完成主题")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black.opacity(0.9))
                .padding(.top, 24)
            
            Text("《\(themeName)》")
                .font(.system(size: 17))
                .foregroundColor(.black.opacity(0.6))
                .padding(.top, 8)
            
            // 统计数据
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("正念时长")
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.6))
                    Text("\(formattedTime)分钟")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("正念字数")
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.6))
                    Text(formattedCharacterCount)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("累计练习")
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.6))
                    Text(formattedPracticeCount)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                }
            }
            .padding(.top, 48)
            
            Spacer()
            
            // 完成按钮
            Button(action: {
                // 关闭所有页面直到返回探索页面
                isPresented = false
                dismiss()
            }) {
                Text("我真棒")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 0.25, green: 0.25, blue: 0.35))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .ignoresSafeArea()
    }
}

#Preview {
    ThemeCompletionView(
        isPresented: .constant(true),
        themeName: "好好爱自己",
        mindfulnessTime: 12,
        characterCount: 6,
        practiceCount: 3
    )
} 