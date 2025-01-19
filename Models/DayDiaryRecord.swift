import Foundation

class DayDiaryRecord {
    static let shared = DayDiaryRecord()
    private let defaults = UserDefaults.standard
    private let currentRecordKey = "currentDayDiaryRecord"
    private let recordsKey = "dayDiaryRecords"
    
    private init() {}
    
    // 当前记录
    private var currentRecord: Record?
    
    // 记录结构
    struct Record: Codable {
        let startTime: Date
        let endTime: Date
        let duration: TimeInterval
        let feeling: Int  // 1-5 的感觉程度
        let events: [String]
        let eventDescription: String
        let futureExpectation: String
        let wordCount: Int
        
        init(startTime: Date, feeling: Int, events: [String], eventDescription: String, futureExpectation: String) {
            self.startTime = startTime
            self.endTime = Date()
            self.duration = self.endTime.timeIntervalSince(startTime)
            self.feeling = feeling
            self.events = events
            self.eventDescription = eventDescription
            self.futureExpectation = futureExpectation
            self.wordCount = eventDescription.count + futureExpectation.count
        }
    }
    
    // 保存记录
    func saveRecord(startTime: Date, feeling: Int, events: [String], eventDescription: String, futureExpectation: String) {
        let record = Record(
            startTime: startTime,
            feeling: feeling,
            events: events,
            eventDescription: eventDescription,
            futureExpectation: futureExpectation
        )
        currentRecord = record
        
        // 保存到 UserDefaults
        if let encoded = try? JSONEncoder().encode(record) {
            defaults.set(encoded, forKey: currentRecordKey)
            
            // 同时保存到历史记录
            var records = getAllRecords()
            records.append(record)
            if let encodedRecords = try? JSONEncoder().encode(records) {
                defaults.set(encodedRecords, forKey: recordsKey)
            }
            
            // 更新完成状态
            MorningCompletionRecord.shared.recordCompletion()
            
            // 发送刷新日记列表的通知
            NotificationCenter.default.post(
                name: NSNotification.Name("RefreshDiaryEntries"),
                object: nil
            )
        }
    }
    
    // 获取当前记录
    func getCurrentRecord() -> Record? {
        if let currentRecord = currentRecord {
            return currentRecord
        }
        
        // 从 UserDefaults 读取
        if let savedRecord = defaults.data(forKey: currentRecordKey),
           let decoded = try? JSONDecoder().decode(Record.self, from: savedRecord) {
            currentRecord = decoded
            return decoded
        }
        
        // 如果当前记录不存在，返回最新的历史记录
        return getAllRecords().last
    }
    
    // 获取所有记录
    func getAllRecords() -> [Record] {
        if let savedRecords = defaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([Record].self, from: savedRecords) {
            return decoded
        }
        return []
    }
    
    // 清除当前记录
    func clearCurrentRecord() {
        currentRecord = nil
        defaults.removeObject(forKey: currentRecordKey)
    }
} 