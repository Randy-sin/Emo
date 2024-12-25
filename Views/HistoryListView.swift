import SwiftUI

struct HistoryListView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // 筛选状态
    @State private var selectedTimeRange: TimeFilter = .all
    @State private var selectedEmotionType: EmotionType?
    @State private var searchText = ""
    
    // 时间筛选选项
    enum TimeFilter: String, CaseIterable {
        case today = "今天"
        case week = "本周"
        case month = "本月"
        case all = "全部"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 筛选栏
                filterBar
                
                // 记录列表
                recordsList
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 筛选栏
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    filterButton(filter)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // 筛选按钮
    private func filterButton(_ filter: TimeFilter) -> some View {
        Button(action: {
            withAnimation {
                selectedTimeRange = filter
            }
        }) {
            Text(filter.rawValue)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedTimeRange == filter ?
                            LinearGradient(colors: [.blue, .purple],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom))
                )
                .foregroundColor(selectedTimeRange == filter ? .white : .secondary)
                .overlay(
                    Capsule()
                        .strokeBorder(selectedTimeRange == filter ? Color.clear :
                            Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // 记录列表
    private var recordsList: some View {
        List {
            ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                Section(header: dateHeader(date)) {
                    ForEach(groupedRecords[date] ?? []) { record in
                        RecordRow(record: record)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color(.systemBackground))
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // 日期头部视图
    private func dateHeader(_ date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 当天的情绪统计
            if let records = groupedRecords[date] {
                Text("共\(records.count)条记录")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
        .background(Color(.systemGroupedBackground))
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
    
    // 按日期分组的记录
    private var groupedRecords: [Date: [EmotionRecord]] {
        let calendar = Calendar.current
        let records = filteredRecords
        
        var grouped: [Date: [EmotionRecord]] = [:]
        for record in records {
            let date = calendar.startOfDay(for: record.timestamp)
            if grouped[date] == nil {
                grouped[date] = []
            }
            grouped[date]?.append(record)
        }
        
        // 对每一天的记录按时间排序
        for (date, records) in grouped {
            grouped[date] = records.sorted { $0.timestamp > $1.timestamp }
        }
        
        return grouped
    }
    
    // 根据筛选条件过滤记录
    private var filteredRecords: [EmotionRecord] {
        var records = viewModel.getAllRecords()
        
        // 应用时间筛选
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .today:
            records = records.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            records = records.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            records = records.filter { $0.timestamp >= monthAgo }
        case .all:
            break
        }
        
        return records
    }
}

#Preview {
    HistoryListView(viewModel: EmotionViewModel())
} 