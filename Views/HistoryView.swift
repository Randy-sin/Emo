import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = EmotionViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 情绪概览卡片
                    EmotionSummaryCard(summary: viewModel.getEmotionSummary())
                    
                    // 常用标签云
                    TagCloudView(tags: viewModel.getTopTags())
                    
                    // 近期记录列表
                    RecentRecordsView(records: viewModel.records)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("情绪历史")
            .onAppear {
                viewModel.loadRecords()
                viewModel.updateStats()
            }
        }
    }
}

struct EmotionSummaryCard: View {
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("情绪概览", systemImage: "chart.bar.fill")
                .font(.headline)
            
            Text(summary)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct TagCloudView: View {
    let tags: [(tag: String, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("常用标签", systemImage: "tag.fill")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.tag) { tag in
                    Text("\(tag.tag) (\(tag.count))")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct RecentRecordsView: View {
    let records: [EmotionRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("近期记录", systemImage: "clock.fill")
                .font(.headline)
            
            ForEach(records) { record in
                EmotionRecordCard(record: record)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EmotionRecordCard: View {
    let record: EmotionRecord
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(record.emoji)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(formatDate(record.timestamp))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 15) {
                        Label("强度 \(record.intensity)", systemImage: "bolt.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        if record.note != nil || !record.tags.isEmpty {
                            Button(action: {
                                withAnimation(.spring()) {
                                    isExpanded.toggle()
                                }
                            }) {
                                Label(isExpanded ? "收起" : "展开", systemImage: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if let note = record.note {
                        Text(note)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                    
                    if !record.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(record.tags, id: \.self) { tag in
                                    Text(tag)
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
                        }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
