//
//  ExploreView.swift
//  EmoEase
//
//  Created by Randy on 18/01/2025.
//

import SwiftUI

// MARK: - Models
// 主题日记模型
struct ThemeDiary: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let type: ThemeType  // 添加主题类型
}

struct ExploreView: View {
    @State private var showChat = false
    @Environment(\.colorScheme) var colorScheme
    
    // 示例数据
    private let themeDiaries = [
        ThemeDiary(
            icon: "heart.square.fill",
            title: "好好爱自己",
            description: "练习将自己放在第一位，以善意和尊重的态度对待自己...",
            type: .selfLove
        ),
        ThemeDiary(
            icon: "umbrella.fill",
            title: "关心自己",
            description: "在这个快节奏的生活中，我们常常忘记关心自己。这个主题将帮助你学会觉察自己的需要，建立健康的自我关怀习惯...",
            type: .selfCare
        ),
        ThemeDiary(
            icon: "leaf.fill",
            title: "打造自己的幸福",
            description: "打造独属于自己的幸福之路。邀请你开启一段美好的旅程...",
            type: .buildHappiness
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 最新主题日记区域
                VStack(alignment: .leading, spacing: 16) {
                    Text("最新主题日记")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // 主题日记卡片滚动视图
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(themeDiaries) { diary in
                                ThemeDiaryCard(diary: diary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 对话助手区域
                VStack(spacing: 16) {
                    Button(action: {
                        showChat = true
                    }) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("对话助手")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("随时倾诉，获得温暖支持")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "message.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
                
                // 底部推荐区域
                VStack(alignment: .leading, spacing: 16) {
                    Text("每日推荐")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        RecommendationCard(
                            icon: "book.fill",
                            title: "情绪日记",
                            description: "记录每一天的心情变化",
                            color: .blue
                        )
                        
                        RecommendationCard(
                            icon: "heart.fill",
                            title: "正念冥想",
                            description: "15分钟的心灵沉淀",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showChat) {
            ChatView()
        }
    }
}

// 主题日记卡片
struct ThemeDiaryCard: View {
    let diary: ThemeDiary
    @State private var showDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标
            Image(systemName: diary.icon)
                .foregroundColor(.orange)
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                )
            
            // 标题
            Text(diary.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 描述
            Text(diary.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            showDetail = true
        }
        .fullScreenCover(isPresented: $showDetail) {
            ThemeDiaryDetailView(isPresented: $showDetail, themeType: diary.type)
        }
    }
}

// 推荐卡片
struct RecommendationCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    ExploreView()
}