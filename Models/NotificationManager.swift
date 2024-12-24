import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 请求通知权限
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限获取成功")
                self.scheduleAllNotifications()
            } else if let error = error {
                print("通知权限获取失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 调度所有通知
    func scheduleAllNotifications() {
        // 移除所有现有的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 设置早安日记提醒 (每天早上 8:00)
        scheduleMorningDiaryNotification()
        
        // 设置情绪记录提醒 (每天中午 12:00)
        scheduleEmotionRecordNotification()
        
        // 设置晚安日记提醒 (每天晚上 22:00)
        scheduleNightDiaryNotification()
    }
    
    // 设置早安日记提醒
    private func scheduleMorningDiaryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "早安日记"
        content.body = "新的一天开始啦！记录一下今天的期待吧 ☀️"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morningDiary", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // 设置情绪记录提醒
    private func scheduleEmotionRecordNotification() {
        let content = UNMutableNotificationContent()
        content.title = "情绪记录"
        content.body = "停下来，记录一下此刻的心情吧 💭"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "emotionRecord", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // 设置晚安日记提醒
    private func scheduleNightDiaryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "晚安日记"
        content.body = "今天过得如何？记录一下美好的回忆吧 🌙"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "nightDiary", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // 检查通知权限状态
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
} 