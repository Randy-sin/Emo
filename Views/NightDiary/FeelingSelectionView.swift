import SwiftUI

extension NightDiary {
    struct FeelingSelectionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        @State private var selectedLevel: Int? = nil
        @State private var showingEventSelection = false
        
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
                    Text("今天感觉如何？")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("太阳越大代表感觉越好")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // 太阳选择器
                HStack(spacing: 25) {
                    ForEach(0..<5) { index in
                        SunButton(level: index, isSelected: selectedLevel == index) {
                            selectedLevel = index
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)  // 与文字的间距
                
                Spacer()
                
                // 下一步按钮
                NavigationLink(destination: EventSelectionView(
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
    
    // 太阳按钮组件
    private struct SunButton: View {
        let level: Int
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: CGFloat(30 + level * 8)) // 太阳大小逐级递增
                    .foregroundColor(isSelected ? .yellow : .yellow.opacity(0.3))
            }
        }
    }
}

#Preview {
    NavigationView {
        NightDiary.FeelingSelectionView(startTime: Date())
    }
} 