import SwiftUI

extension NightDiary {
    struct NightDiaryView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var showingFeelingSelection = false
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 60)  // 顶部留白
                            
                        // 顶部图标
                        Image("icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                        
                        Spacer()
                            .frame(height: 20)  // 图标和文字之间的间距
                        
                        // 标题和介绍文字
                        VStack(spacing: 16) {
                            Text("晚安日记·温馨总结")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("回顾一天的点滴，思考今日的专注与收获，为自己感到满足与踏实。充满希望地展望明天，相信一切都会更好。让我们好好休息，迎接新的开始吧！ 🌙")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 30)
                        }
                        
                        Spacer()
                            .frame(height: 40)  // 文字和按钮之间的间距
                        
                        // 开始按钮
                        NavigationLink(destination: FeelingSelectionView(startTime: Date())) {
                            Text("开始")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.purple)
                                .cornerRadius(25)
                                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Spacer()
                            .frame(height: 100)  // 底部留白
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemBackground))
                .navigationBarTitleDisplayMode(.inline)
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
            .navigationViewStyle(.stack)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
                dismiss()
            }
        }
    }
}

#Preview {
    NightDiary.NightDiaryView()
} 