import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject private var viewModel = EmotionViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedEmotionType: EmotionType?
    @State private var showingDetail = false
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "近7天"
        case month = "近30天"
        case year = "近一年"
    }
    
    var body: some View {
        ScrollView {
            contentView
        }
        .navigationTitle("心情记录")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.loadRecords()
            viewModel.updateStats()
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 24) {
            timeRangeView
            trendView
            distributionView
            recordListView
        }
        .padding()
    }
    
    private var timeRangeView: some View {
        TimeRangeSelector(selectedRange: $selectedTimeRange)
    }
    
    private var trendView: some View {
        EmotionTrendCard(viewModel: viewModel, timeRange: selectedTimeRange)
    }
    
    private var distributionView: some View {
        EmotionDistributionCard(viewModel: viewModel)
    }
    
    private var recordListView: some View {
        RecordListCard(viewModel: viewModel)
    }
}

// 时间范围选择器
struct TimeRangeSelector: View {
    @Binding var selectedRange: HistoryView.TimeRange
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(HistoryView.TimeRange.allCases, id: \.self) { range in
                rangeButton(for: range)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func rangeButton(for range: HistoryView.TimeRange) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedRange = range
            }
        }) {
            buttonLabel(for: range)
        }
    }
    
    private func buttonLabel(for range: HistoryView.TimeRange) -> some View {
        Text(range.rawValue)
            .font(.system(size: 15, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(buttonBackground(for: range))
            .foregroundColor(selectedRange == range ? .white : .secondary)
            .overlay(buttonBorder(for: range))
    }
    
    private func buttonBackground(for range: HistoryView.TimeRange) -> some View {
        Capsule()
            .fill(selectedRange == range ?
                LinearGradient(colors: [.blue, .purple],
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing) :
                LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom))
    }
    
    private func buttonBorder(for range: HistoryView.TimeRange) -> some View {
        Capsule()
            .strokeBorder(selectedRange == range ? Color.clear :
                Color.secondary.opacity(0.2), lineWidth: 1)
    }
}

// 情绪趋势卡片
struct EmotionTrendCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    let timeRange: HistoryView.TimeRange
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        cardView
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardTitle
            chartView
        }
        .padding(20)
        .background(cardBackground)
    }
    
    private var cardTitle: some View {
        Label {
            Text("情绪变化趋势")
                .font(.system(size: 17, weight: .semibold))
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(.linearGradient(colors: [.blue, .purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(viewModel.getEmotionTrend(for: timeRange)) { point in
                LineMark(
                    x: .value("日期", point.date),
                    y: .value("强度", point.intensity)
                )
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple],
                                 startPoint: .bottom,
                                 endPoint: .top)
                )
                
                AreaMark(
                    x: .value("日期", point.date),
                    y: .value("强度", point.intensity)
                )
                .foregroundStyle(
                    LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                                 startPoint: .top,
                                 endPoint: .bottom)
                )
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date.formatted(.dateTime.month().day()))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                   radius: 15, x: 0, y: 5)
    }
}

// 情绪分布卡片
struct EmotionDistributionCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        cardView
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardTitle
            distributionGrid
        }
        .padding(20)
        .background(cardBackground)
    }
    
    private var cardTitle: some View {
        Label {
            Text("情绪分布")
                .font(.system(size: 17, weight: .semibold))
        } icon: {
            Image(systemName: "chart.pie.fill")
                .foregroundStyle(.linearGradient(colors: [.orange, .pink],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
        }
    }
    
    private var distributionGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(viewModel.getEmotionDistribution()) { item in
                EmotionTypeCard(type: item.type, count: item.count, percentage: item.percentage)
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                   radius: 15, x: 0, y: 5)
    }
}

// 情绪类型卡片
struct EmotionTypeCard: View {
    let type: EmotionType
    let count: Int
    let percentage: Double
    
    var body: some View {
        cardContent
    }
    
    private var cardContent: some View {
        VStack(spacing: 8) {
            emotionLabel
            countLabel
            percentageLabel
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(cardBackground)
    }
    
    private var emotionLabel: some View {
        Text(type.rawValue)
            .font(.system(size: 15, weight: .medium))
    }
    
    private var countLabel: some View {
        Text("\(count)")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
    }
    
    private var percentageLabel: some View {
        Text(String(format: "%.1f%%", percentage))
            .font(.system(size: 13))
            .foregroundColor(.secondary)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(type.color.opacity(0.1))
    }
}

// 记录列表卡片
struct RecordListCard: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedRecord: EmotionRecord?
    @State private var showingDetail = false
    @State private var showingHistoryList = false
    
    var body: some View {
        cardView
            .sheet(isPresented: $showingDetail) {
                if let record = selectedRecord {
                    RecordDetailView(record: record)
                }
            }
            .sheet(isPresented: $showingHistoryList) {
                HistoryListView(viewModel: viewModel)
            }
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardTitle
            recordsList
            viewMoreButton
        }
        .padding(20)
        .background(cardBackground)
    }
    
    private var cardTitle: some View {
        Label {
            Text("详细记录")
                .font(.system(size: 17, weight: .semibold))
        } icon: {
            Image(systemName: "list.bullet.rectangle.fill")
                .foregroundStyle(.linearGradient(colors: [.green, .mint],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
        }
    }
    
    private var recordsList: some View {
        ForEach(viewModel.getAllRecords().prefix(5)) { record in
            RecordRow(record: record)
                .onTapGesture {
                    selectedRecord = record
                    showingDetail = true
                }
            
            if record.id != viewModel.getAllRecords().prefix(5).last?.id {
                Divider()
            }
        }
    }
    
    private var viewMoreButton: some View {
        Button(action: {
            showingHistoryList = true
        }) {
            Text("查看更多")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                   radius: 15, x: 0, y: 5)
    }
}

// 记录行视图
struct RecordRow: View {
    let record: EmotionRecord
    @State private var isPressed = false
    
    // 将情绪文字映射为emoji
    private func getEmoji(for type: EmotionType) -> String {
        switch type {
        case .happy: return "😊"
        case .calm: return "😌"
        case .anxious: return "😰"
        case .stress: return "😓"
        case .angry: return "😠"
        case .breathing: return "😮‍💨"
        case .closing: return "😌"
        case .inhalation: return "🫁"
        case .inflation: return "😤"
        case .joyful: return "🥳"
        case .pardons: return "🤝"
        case .rhythms: return "🎵"
        case .tired: return "😪"
        case .etc: return "🤔"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 情绪图标
            emotionIcon
            
            // 记录信息
            recordInfo
            
            Spacer()
            
            // 强度指示器
            IntensityIndicator(value: record.intensity)
        }
        .padding(.vertical, 8)
    }
    
    private var emotionIcon: some View {
        ZStack {
            // 背景圆圈
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            (EmotionType(rawValue: record.emoji) ?? .etc).color.opacity(0.2),
                            (EmotionType(rawValue: record.emoji) ?? .etc).color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            // emoji
            if let type = EmotionType(rawValue: record.emoji) {
                Text(getEmoji(for: type))
                    .font(.system(size: 24))
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
    
    private var recordInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 时间和情绪描述
            HStack {
                Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 15, weight: .medium))
                
                if let type = EmotionType(rawValue: record.emoji) {
                    Text(type.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            // 标签
            if !record.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(record.tags.prefix(3), id: \.self) { tag in
                            TagView(tag: tag, color: (EmotionType(rawValue: record.emoji) ?? .etc).color)
                        }
                        
                        if record.tags.count > 3 {
                            Text("+\(record.tags.count - 3)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
}

// 标签视图
struct TagView: View {
    let tag: String
    let color: Color
    
    var body: some View {
        Text(tag)
            .font(.system(size: 13))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(color)
    }
}

// 强度指示器
struct IntensityIndicator: View {
    let value: Int
    @State private var showingIntensityInfo = false
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(indicatorBackground)
            .onTapGesture {
                showingIntensityInfo = true
            }
            .sheet(isPresented: $showingIntensityInfo) {
                IntensityInfoView(value: value)
            }
    }
    
    private var indicatorBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// 情绪强度说明视图
struct IntensityInfoView: View {
    let value: Int
    @Environment(\.dismiss) private var dismiss
    
    // 强度等级说明
    private let intensityDescriptions = [
        1: "轻微: 情绪变化很小，几乎感觉不到",
        2: "温和: 能感觉到情绪变化，但不影响日常生活",
        3: "中等: 明显的情绪变化，会影响一部分注意力",
        4: "强烈: 很强的情绪体验，难以集中注意力",
        5: "极强: 情绪非常强烈，完全无法控制"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 当前强度指示
                VStack(spacing: 16) {
                    Text("情绪强度说明")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text("当前强度")
                            .foregroundColor(.secondary)
                        Text("\(value)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // 强度等级说明
                VStack(alignment: .leading, spacing: 16) {
                    Text("强度等级参考")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    ForEach(1...5, id: \.self) { level in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(level)")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(level == value ? .blue : .primary)
                                .frame(width: 24)
                            
                            Text(intensityDescriptions[level] ?? "")
                                .font(.system(.body))
                                .foregroundColor(level == value ? .primary : .secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(level == value ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
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
}

// 记录详情视图
struct RecordDetailView: View {
    let record: EmotionRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                contentView
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    dismissButton
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 24) {
            emotionSection
            if !record.tags.isEmpty {
                tagsSection
            }
            timeSection
        }
        .padding()
    }
    
    private var emotionSection: some View {
        VStack(spacing: 16) {
            Text(record.emoji)
                .font(.system(size: 64))
            
            HStack(spacing: 8) {
                Text("强度")
                    .foregroundColor(.secondary)
                Text("\(record.intensity)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(sectionBackground)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("标签")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(record.tags, id: \.self) { tag in
                    tagView(tag)
                }
            }
        }
        .padding()
        .background(sectionBackground)
    }
    
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("记录时间")
                .font(.headline)
            
            Text(record.timestamp.formatted(date: .complete, time: .complete))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(sectionBackground)
    }
    
    private func tagView(_ tag: String) -> some View {
        Text(tag)
            .font(.system(size: 15))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
    }
    
    private var sectionBackground: some View {
        Color(.systemBackground)
            .cornerRadius(20)
    }
    
    private var dismissButton: some View {
        Button("完成") {
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
