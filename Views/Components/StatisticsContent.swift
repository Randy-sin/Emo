import SwiftUI

struct StatisticsContent: View {
    let stats: EmotionStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 总体统计
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
            
            // 情绪分布
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("最常见情绪")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.system(size: 14))
                }
                
                if stats.totalCount < 3 {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary.opacity(0.7))
                            .font(.system(size: 14))
                        Text("记录3条以上情绪，即可查看统计分析")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Text(stats.formattedMostFrequentEmotion)
                        .font(.system(size: 20, weight: .medium))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // 标签云
            if !stats.tagCounts.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("常用标签")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.teal)
                            .font(.system(size: 14))
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(Array(stats.tagCounts.sorted(by: { $0.value > $1.value }).prefix(3)), id: \.key) { tag, count in
                            TagChip(text: "\(tag)(\(count))")
                        }
                    }
                }
            }
        }
        .padding(20)
    }
}

// 统计卡片组件
private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标和标题
            Label {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            
            // 数值
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// 标签组件
private struct TagChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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