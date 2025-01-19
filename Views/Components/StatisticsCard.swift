import SwiftUI

struct StatisticsCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // 颜色定义 - 基于色彩心理学
    private let titleGradient = [
        Color(red: 0.45, green: 0.51, blue: 0.99),  // 主色调蓝色
        Color(red: 0.76, green: 0.55, blue: 0.99)   // 渐变到紫色
    ]
    
    private let recordCountColors = [
        Color(red: 0.35, green: 0.56, blue: 0.96),  // 可靠的蓝色
        Color(red: 0.45, green: 0.65, blue: 0.99)   // 明亮的蓝色
    ]
    
    private let averageIntensityColors = [
        Color(red: 1.0, green: 0.62, blue: 0.27),   // 温暖的橙色
        Color(red: 1.0, green: 0.72, blue: 0.37)    // 明亮的橙色
    ]
    
    private let mostFrequentColors = [
        Color(red: 0.67, green: 0.47, blue: 0.95),  // 优雅的紫色
        Color(red: 0.78, green: 0.57, blue: 0.99)   // 明亮的紫色
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题栏
            HStack {
                Label {
                    Text("统计概览")
                        .font(.system(size: 20, design: .rounded))
                } icon: {
                    Image("Statistics")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            if let stats = viewModel.emotionStats {
                VStack(spacing: 25) {
                    // 主要统计数据
                    HStack(spacing: 15) {
                        StatCircle(
                            value: "\(stats.totalCount)",
                            title: "记录总数",
                            icon: "note.text",
                            gradient: recordCountColors
                        )
                        
                        StatCircle(
                            value: String(format: "%.1f", stats.averageIntensity),
                            title: "平均强度",
                            icon: "gauge",
                            gradient: averageIntensityColors
                        )
                        
                        StatCircle(
                            value: "\(stats.getMostFrequentEmotions(limit: 1).first?.1 ?? 0)",
                            title: "最多次数",
                            icon: "heart.fill",
                            gradient: mostFrequentColors
                        )
                    }
                    
                    // 最常见情绪展示
                    if stats.totalCount >= 3 {
                        VStack(alignment: .leading, spacing: 20) {
                            // 情绪分布部分
                            VStack(alignment: .leading, spacing: 15) {
                                Label {
                                    Text("情绪分布")
                                        .font(.system(size: 17, weight: .medium))
                                } icon: {
                                    Image("Normal Distribution Histogram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                }
                                .foregroundColor(.secondary)
                                
                                EmotionBarChart(stats: stats)
                                    .frame(height: 160)
                            }
                            
                            // 常用标签部分
                            VStack(alignment: .leading, spacing: 15) {
                                Label {
                                    Text("常用标签")
                                        .font(.system(size: 17, weight: .medium))
                                } icon: {
                                    Image("tag")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                }
                                .foregroundColor(.secondary)
                                
                                TagCloud(tags: stats.getTopTags(limit: 6))
                            }
                        }
                        .padding(.vertical, 10)
                    } else {
                        InfoBox(
                            icon: "info.circle.fill",
                            title: "记录3条以上情绪",
                            subtitle: "即可查看详细的情绪分布分析"
                        )
                    }
                }
            } else {
                // 无数据状态
                EmptyStateView()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                       radius: 15, x: 0, y: 5)
        )
    }
}

// 小节标题组件
struct SectionTitle: View {
    let icon: String
    let title: String
    let colors: [Color]
    
    var body: some View {
        Label {
            Text(title)
                .font(.system(size: 17, weight: .medium))
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(.linearGradient(colors: colors,
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
        }
        .foregroundColor(.secondary)
    }
}

// 标签云组件
struct TagCloud: View {
    let tags: [(String, Int)]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        FlowLayout(spacing: 10) {
            ForEach(tags, id: \.0) { tag, count in
                TagBubble(text: tag, count: count)
            }
        }
    }
}

// 标签气泡组件
struct TagBubble: View {
    let text: String
    let count: Int
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedTab") var selectedTab: Int = 0
    
    // 根据标签内容返回对应的渐变色
    private var tagColors: [Color] {
        switch text {
        case "开心", "充实", "轻松":  // 积极情绪
            return [
                Color(red: 0.0, green: 0.6, blue: 0.99),   // 蓝色系：代表平静、信任
                Color(red: 0.2, green: 0.7, blue: 0.99)
            ]
        case "呼吸练习", "精进":      // 成长相关
            return [
                Color(red: 0.4, green: 0.8, blue: 0.6),    // 绿色系：代表成长、希望
                Color(red: 0.5, green: 0.9, blue: 0.7)
            ]
        case "焦虑", "生气", "deadline":  // 压力相关
            return [
                Color(red: 0.99, green: 0.3, blue: 0.4),   // 红色系：代表紧张、警示
                Color(red: 0.99, green: 0.4, blue: 0.5)
            ]
        default:                      // 其他标签
            return [
                Color(red: 0.67, green: 0.47, blue: 0.95),  // 紫色系：代表创造、平衡
                Color(red: 0.78, green: 0.57, blue: 0.99)
            ]
        }
    }
    
    private var bubbleGradient: LinearGradient {
        LinearGradient(
            colors: tagColors.map { $0.opacity(colorScheme == .dark ? 0.15 : 0.08) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var textGradient: LinearGradient {
        LinearGradient(
            colors: tagColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var countBackgroundColor: Color {
        colorScheme == .dark ? 
            Color.white.opacity(0.1) : 
            tagColors[0].opacity(0.08)
    }
    
    var body: some View {
        Button(action: {
            // 切换到历史标签页（假设历史是第4个标签，索引为3）
            selectedTab = 3
        }) {
            HStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(textGradient)
                
                Text("\(count)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(countBackgroundColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(bubbleGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: tagColors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}

// 情绪柱状图
struct EmotionBarChart: View {
    let stats: EmotionStats
    @Environment(\.colorScheme) var colorScheme
    
    private func getGradientColors(for category: EmotionCategory) -> [Color] {
        switch category {
        case .positive:
            return [
                Color(red: 0.0, green: 0.6, blue: 0.99),  // 明亮的蓝色
                Color(red: 0.2, green: 0.7, blue: 0.99)   // 浅蓝色
            ]
        case .negative:
            return [
                Color(red: 0.99, green: 0.3, blue: 0.4),  // 鲜艳的红色
                Color(red: 0.99, green: 0.4, blue: 0.5)   // 浅红色
            ]
        case .neutral:
            return [
                Color(red: 0.6, green: 0.4, blue: 0.98),  // 深紫色
                Color(red: 0.7, green: 0.5, blue: 0.99)   // 浅紫色
            ]
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(stats.getMostFrequentEmotions(limit: 5), id: \.0) { emotion, count in
                VStack(spacing: 8) {
                    // 数值
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // 柱状图
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: getGradientColors(for: emotion.category),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 45, height: getBarHeight(count: count))
                    
                    // 情绪类型
                    VStack(spacing: 4) {
                        Text(emotion.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(LinearGradient(
                                colors: getGradientColors(for: emotion.category),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        Text("\(Int(getPercentage(count: count)))%")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: stats.totalCount)
    }
    
    private func getBarHeight(count: Int) -> CGFloat {
        let maxHeight: CGFloat = 100
        let maxCount = stats.getMostFrequentEmotions(limit: 5).map { $0.1 }.max() ?? 1
        return max(30, (CGFloat(count) / CGFloat(maxCount)) * maxHeight)
    }
    
    private func getPercentage(count: Int) -> Double {
        Double(count) / Double(stats.totalCount) * 100
    }
}

// 信息提示框
struct InfoBox: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 无数据状态视图
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("暂无数据")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("记录你的第一个情绪，开始追踪心情变化")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
    }
}

// 统计圆形组件
struct StatCircle: View {
    let value: String
    let title: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: gradient.map { $0.opacity(0.15) },
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: gradient,
                                                      startPoint: .topLeading,
                                                      endPoint: .bottomTrailing))
                    
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: gradient,
                                                      startPoint: .topLeading,
                                                      endPoint: .bottomTrailing))
                }
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StatisticsCard(viewModel: EmotionViewModel())
        .padding()
        .background(Color(.systemGroupedBackground))
} 