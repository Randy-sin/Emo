import SwiftUI

class PracticeStatsService: ObservableObject {
    @Published var practiceCount: Int
    private let practiceCountKey = "practiceCount"
    
    // 添加静态共享实例
    static let shared = PracticeStatsService()
    
    private init() {  // 使构造器私有化
        // 从 UserDefaults 读取历史练习次数
        practiceCount = UserDefaults.standard.integer(forKey: practiceCountKey)
        print("Initialized PracticeStatsService with count: \(practiceCount)")
    }
    
    func incrementPracticeCount() {
        practiceCount += 1
        // 保存到 UserDefaults
        UserDefaults.standard.set(practiceCount, forKey: practiceCountKey)
        print("Practice completed! Total count: \(practiceCount)")
    }
    
    // 用于测试的重置方法
    func resetCount() {
        practiceCount = 0
        UserDefaults.standard.set(0, forKey: practiceCountKey)
        print("Reset practice count to 0")
    }
} 