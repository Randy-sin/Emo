import SwiftUI

struct StatisticsContent: View {
    let stats: EmotionStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 总体统计
            HStack(spacing: 20) {
                StatItem(
                    title: "记录总数",
                    value: "\(stats.totalCount)",
                    icon: "note.text"
                )
                
                StatItem(
                    title: "平均强度",
                    value: String(format: "%.1f", stats.averageIntensity),
                    icon: "gauge"
                )
            }
            
            Divider()
            
            // 情绪分布
            HStack {
                Label {
                    Text("最常见情绪")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text(stats.formattedMostFrequentEmotion)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
            }
            
            // 标签云
            if !stats.tagCounts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("常用标签")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.blue)
                    }
                    
                    FlowLayout(spacing: 8) {
                        ForEach(Array(stats.tagCounts.sorted(by: { $0.value > $1.value }).prefix(3)), id: \.key) { tag, count in
                            TagChip(text: "\(tag)(\(count))")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// 统计项组件
private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            }
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.medium)
        }
    }
}

// 标签组件
private struct TagChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
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