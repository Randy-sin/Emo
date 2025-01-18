import SwiftUI

struct DiaryView: View {
    @StateObject private var diaryViewModel = DiaryViewModel()
    @StateObject private var emotionViewModel = EmotionViewModel()
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        DiaryContentView(
            entries: diaryViewModel.entries,
            searchText: $searchText,
            colorScheme: colorScheme
        )
        .navigationTitle("日记")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "搜索日记")
        .onChange(of: searchText) { oldValue, newValue in
            diaryViewModel.filterEntries(newValue)
        }
        .onAppear {
            diaryViewModel.loadEntries()
        }
    }
}

// 日记内容视图
private struct DiaryContentView: View {
    let entries: [DiaryEntry]
    @Binding var searchText: String
    let colorScheme: ColorScheme
    
    // 按日期分组的条目
    private var groupedEntries: [Date: [DiaryEntry]] {
        let calendar = Calendar.current
        var result = [Date: [DiaryEntry]]()
        
        for entry in entries {
            let date = calendar.startOfDay(for: entry.timestamp)
            if result[date] == nil {
                result[date] = []
            }
            result[date]?.append(entry)
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SearchBar(text: $searchText)
                
                DiaryListView(
                    entries: groupedEntries,
                    colorScheme: colorScheme
                )
                .padding(.horizontal)
            }
        }
    }
}

// 日记列表视图
private struct DiaryListView: View {
    let entries: [Date: [DiaryEntry]]
    let colorScheme: ColorScheme
    
    var body: some View {
        LazyVStack(spacing: 15, pinnedViews: .sectionHeaders) {
            ForEach(Array(entries.keys.sorted(by: >)), id: \.self) { date in
                Section(header: DateHeaderView(date: date, colorScheme: colorScheme)) {
                    ForEach(entries[date] ?? []) { entry in
                        DiaryEntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

// 日期头部视图
private struct DateHeaderView: View {
    let date: Date
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            Text(relativeDateString(for: date))
                .font(.system(size: 15, weight: .medium))
            
            Text(date.formatted(.dateTime.month().day()))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    private func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let weekday = calendar.component(.weekday, from: date)
            let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
            return weekdays[weekday - 1]
        }
    }
}

// 日记条目行组件
struct DiaryEntryRow: View {
    let entry: DiaryEntry
    @State private var showingPreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 右上角时间
            HStack {
                let headerText: Text = switch entry.type {
                case .night:
                    Text("晚安日记")
                case .morning:
                    Text("早安日记")
                case .emotion:
                    Text("心情日记")
                }
                
                headerText
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // 中间内容
            HStack(spacing: 12) {
                switch entry.type {
                case .night:
                    Image("moon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                case .morning:
                    Image(systemName: entry.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                case .emotion(_, let type):
                    if type == .happy {
                        Image("happy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .calm {
                        Image("relieved")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .anxious {
                        Image("anxious")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .stress {
                        Image("stress")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .angry {
                        Image("angry")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .breathing {
                        Image("breathing")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .closing {
                        Image("closing")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .inhalation {
                        Image("inhalation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .inflation {
                        Image("inflation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .joyful {
                        Image("joyful")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .pardons {
                        Image("pardons")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .rhythms {
                        Image("rhythms")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .tired {
                        Image("tired")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if type == .etc {
                        Image("etc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else {
                        Text(type.emoji)
                            .font(.system(size: 40))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 17, weight: .medium))
                    
                    if let description = entry.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            // 标签
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 13))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .onTapGesture {
            showingPreview = true
        }
        .sheet(isPresented: $showingPreview) {
            DiaryEntryPreview(entry: entry)
        }
    }
}

// 日记预览视图
struct DiaryEntryPreview: View {
    let entry: DiaryEntry
    @StateObject private var emotionViewModel = EmotionViewModel()
    
    var body: some View {
        NavigationView {
            switch entry.type {
            case .night:
                if let record = NightDiaryRecord.shared.getCurrentRecord() {
                    NightDiaryPreview(record: record)
                }
            case .morning:
                if let record = DayDiaryRecord.shared.getCurrentRecord() {
                    DayDiaryPreview(record: record)
                }
            case .emotion(let intensity, _):
                IntensityInfoView(value: intensity)
                    .navigationTitle("记录详情")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            emotionViewModel.loadRecords()
        }
    }
}

#Preview {
    DiaryView()
} 