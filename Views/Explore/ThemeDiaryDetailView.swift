import SwiftUI

struct ThemeDiaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var isLiked = false
    @State private var showQuestionView = false
    @State private var showCompletion = false
    
    // 添加主题相关属性
    let themeType: ThemeType
    
    // 创建 ThemeStats 实例
    @StateObject private var stats = ThemeStats()
    
    var body: some View {
        ZStack {
            // 主要内容
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部导航栏
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 22))
                                .foregroundColor(.black.opacity(0.75))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isLiked.toggle()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 22))
                                .foregroundColor(.black.opacity(0.75))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 主标题
                    Text(themeType.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.horizontal)
                        .padding(.top, 32)
                    
                    // 副标题描述
                    Text(themeType.description)
                        .font(.system(size: 17))
                        .foregroundColor(.black.opacity(0.6))
                        .lineSpacing(8)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 认知技巧标题
                    Text("认知技巧")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.horizontal)
                        .padding(.top, 64)
                    
                    // 认知技巧列表
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(themeType.techniques) { technique in
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.black.opacity(0.15))
                                    .frame(width: 6, height: 6)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(technique.title)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.black.opacity(0.9))
                                    
                                    Text(technique.subtitle)
                                        .font(.system(size: 15))
                                        .foregroundColor(.black.opacity(0.5))
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    
                    // 底部留空，为按钮腾出空间
                    Spacer()
                        .frame(height: 100)
                }
            }
            
            // 固定在底部的开始按钮
            VStack {
                Spacer()
                Button(action: {
                    showQuestionView = true
                }) {
                    Text("开始")
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
        }
        .fullScreenCover(isPresented: $showQuestionView) {
            QuestionView(
                question: themeType.questions[0],
                pageIndex: 0,
                rootIsPresented: $isPresented,
                showCompletion: $showCompletion,
                themeType: themeType
            )
            .environmentObject(stats)
            .environmentObject(globalPracticeStats)
        }
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.98, green: 0.90, blue: 0.82), location: 0),
                    .init(color: Color(red: 0.99, green: 0.95, blue: 0.90), location: 0.3),
                    .init(color: Color(red: 1, green: 0.98, blue: 0.96), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
}

#Preview {
    ThemeDiaryDetailView(isPresented: .constant(true), themeType: .selfLove)
} 