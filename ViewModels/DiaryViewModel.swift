import SwiftUI

// 日记类型
enum DiaryType {
    case night   // 晚安日记
    case emotion(intensity: Int, type: EmotionType) // 情绪记录
    case morning // 早安日记
}

// 日记条目模型
struct DiaryEntry: Identifiable {
    let id = UUID()
    let type: DiaryType
    let title: String
    let timestamp: Date
    let tags: [String]
    let description: String?
    let iconName: String
}

class DiaryViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    private var allEntries: [DiaryEntry] = []
    private var isSearching = false
    
    init() {
        loadEntries()
        // 添加通知观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshEntries),
            name: NSNotification.Name("RefreshDiaryEntries"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func refreshEntries() {
        DispatchQueue.main.async {
            self.loadEntries()
        }
    }
    
    func loadEntries() {
        var entries: [DiaryEntry] = []
        
        // 加载晚安日记
        if let nightRecord = NightDiaryRecord.shared.getCurrentRecord() {
            let entry = DiaryEntry(
                type: .night,
                title: "晚安·好事发生",
                timestamp: nightRecord.startTime,
                tags: nightRecord.events,
                description: nightRecord.eventDescription,
                iconName: "moon.stars.fill"
            )
            entries.append(entry)
        }
        
        // 加载早安日记
        if let morningRecord = DayDiaryRecord.shared.getCurrentRecord() {
            let entry = DiaryEntry(
                type: .morning,
                title: "早安·元气满满",
                timestamp: morningRecord.startTime,
                tags: morningRecord.events,
                description: morningRecord.eventDescription,
                iconName: "sun.max.fill"
            )
            entries.append(entry)
        }
        
        // 加载情绪记录
        let emotionViewModel = EmotionViewModel()
        let emotionRecords = emotionViewModel.records
        for record in emotionRecords {
            if let type = EmotionType(rawValue: record.emoji) {
                let entry = DiaryEntry(
                    type: .emotion(intensity: record.intensity, type: type),
                    title: "情绪记录",
                    timestamp: record.timestamp,
                    tags: record.tags,
                    description: record.note,
                    iconName: type.emoji
                )
                entries.append(entry)
            }
        }
        
        // 按时间排序
        entries.sort { $0.timestamp > $1.timestamp }
        
        self.allEntries = entries
        
        // 如果正在搜索，不更新entries
        if !isSearching {
            withAnimation {
                self.entries = entries
            }
        }
    }
    
    func filterEntries(_ query: String) {
        isSearching = !query.isEmpty
        
        withAnimation {
            if query.isEmpty {
                entries = allEntries
            } else {
                entries = allEntries.filter { entry in
                    entry.title.localizedCaseInsensitiveContains(query) ||
                    entry.tags.contains { $0.localizedCaseInsensitiveContains(query) } ||
                    (entry.description ?? "").localizedCaseInsensitiveContains(query)
                }
            }
        }
    }
} 