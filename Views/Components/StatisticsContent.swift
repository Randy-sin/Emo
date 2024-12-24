import SwiftUI

struct StatisticsContent: View {
    let stats: EmotionStats
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isIPad ? 32 : 24) {
            // 总体统计
            if isIPad {
                // iPad布局：三个卡片并排
                HStack(spacing: 16) {
                    StatCard(
                        title: "记录总数",
                        value: "\(stats.totalCount)",
                        icon: "note.text",
                        color: Color.blue
                    )
                    
                    StatCard(
                        title: "平均强度",
                        value: String(format: "%.1f", stats.averageIntensity),
                        icon: "gauge",
                        color: Color.orange
                    )
                    
                    StatCard(
                        title: "连续记录",
                        value: "\(stats.totalCount)天",
                        icon: "flame.fill",
                        color: Color.red
                    )
                }
                .frame(height: 120)
            } else {
                // iPhone布局：两个卡片
                HStack(spacing: 16) {
                    StatCard(
                        title: "记录总数",
                        value: "\(stats.totalCount)",
                        icon: "note.text",
                        color: Color.blue
                    )
                    
                    StatCard(
                        title: "平均强度",
                        value: String(format: "%.1f", stats.averageIntensity),
                        icon: "gauge",
                        color: Color.orange
                    )
                }
                .frame(height: 100)
            }
            
            // 情绪分布
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("最常见情绪")
                        .font(.system(size: isIPad ? 17 : 15, weight: .medium))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.system(size: isIPad ? 16 : 14))
                }
                
                if stats.totalCount < 3 {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary.opacity(0.7))
                            .font(.system(size: isIPad ? 16 : 14))
                        Text("记录3条以上情绪，即可查看统计分析")
                            .font(.system(size: isIPad ? 16 : 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, isIPad ? 12 : 8)
                    .padding(.horizontal, isIPad ? 16 : 12)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    // iPad上显示更详细的情绪统计
                    if isIPad {
                        VStack(spacing: 16) {
                            Text(stats.formattedMostFrequentEmotion)
                                .font(.system(size: 24, weight: .medium))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(10)
                            
                            // 情绪分布图表
                            EmotionDistributionChart(stats: stats)
                                .frame(height: 120)
                        }
                    } else {
                        Text(stats.formattedMostFrequentEmotion)
                            .font(.system(size: 20, weight: .medium))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
            // 标签云
            if !stats.tagCounts.isEmpty {
                VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
                    Label {
                        Text("常用标签")
                            .font(.system(size: isIPad ? 17 : 15, weight: .medium))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.teal)
                            .font(.system(size: isIPad ? 16 : 14))
                    }
                    
                    if isIPad {
                        // iPad上显示更多标签
                        FlowLayout(spacing: 12) {
                            ForEach(Array(stats.tagCounts.sorted(by: { $0.value > $1.value }).prefix(6)), id: \.key) { tag, count in
                                TagChip(text: "\(tag)(\(count))")
                            }
                        }
                    } else {
                        FlowLayout(spacing: 8) {
                            ForEach(Array(stats.tagCounts.sorted(by: { $0.value > $1.value }).prefix(3)), id: \.key) { tag, count in
                                TagChip(text: "\(tag)(\(count))")
                            }
                        }
                    }
                }
            }
        }
        .padding(isIPad ? 24 : 20)
    }
}

// 情绪分布图表
private struct EmotionDistributionChart: View {
    let stats: EmotionStats
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(stats.getMostFrequentEmotions(limit: 5), id: \.0) { emotion, count in
                VStack {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: CGFloat(count) * 10)
                    
                    Text(emotion.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// 统计卡片组件
private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isIPad ? 16 : 12) {
            // 图标和标题
            Label {
                Text(title)
                    .font(.system(size: isIPad ? 17 : 15, weight: .medium))
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: isIPad ? 16 : 14))
            }
            
            // 数值
            Text(value)
                .font(.system(size: isIPad ? 32 : 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isIPad ? 20 : 16)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                .fill(color.opacity(0.1))
        )
    }
}

// 标签组件
private struct TagChip: View {
    let text: String
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: isIPad ? 16 : 14))
            .padding(.horizontal, isIPad ? 16 : 12)
            .padding(.vertical, isIPad ? 8 : 6)
            .background(
                Capsule()
                    .fill(Color.teal.opacity(0.1))
            )
            .foregroundColor(.teal)
    }
}

#Preview {
    StatisticsContent(stats: EmotionStats(
        totalCount: 42,
        averageIntensity: 3.5,
        emotionTypeCounts: [.happy: 15, .calm: 10, .anxious: 8],
        tagCounts: ["开心": 12, "工作": 8, "家人": 6]
    ))
    .padding()
    .background(Color(.systemBackground))
} 