import SwiftUI

extension DayDiary {
    struct MorningFeelingSelectionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        @State private var selectedLevel: Int? = nil
        
        var body: some View {
            VStack {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("1/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 100)  // 调整顶部空间
                
                // 标题和说明
                VStack(spacing: 12) {
                    Text("昨晚睡得怎么样？")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("月亮越大代表睡眠质量越好")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // 月亮选择器
                HStack(spacing: 25) {
                    ForEach(0..<5) { index in
                        MoonButton(level: index, isSelected: selectedLevel == index) {
                            selectedLevel = index
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)  // 与文字的间距
                
                Spacer()
                
                // 下一步按钮
                NavigationLink(destination: MorningEventSelectionView(
                    startTime: startTime,
                    feeling: (selectedLevel ?? 0) + 1
                )) {
                    Text("下一步")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(selectedLevel != nil ? Color(red: 0.33, green: 0.33, blue: 0.44) : Color.gray)
                        .cornerRadius(27)
                }
                .disabled(selectedLevel == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 17, weight: .medium))
                    }
                }
            }
        }
    }
    
    // 月亮按钮组件
    private struct MoonButton: View {
        let level: Int
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image("moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: CGFloat(30 + level * 8)) // 月亮大小逐级递增
                    .opacity(isSelected ? 1.0 : 0.3)
            }
        }
    }
}

#Preview {
    NavigationView {
        DayDiary.MorningFeelingSelectionView(startTime: Date())
    }
} 