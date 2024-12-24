//
//  EmoEaseApp.swift
//  EmoEase
//
//  Created by Randy on 16/12/2024.
//

import SwiftUI

@main
struct EmoEaseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("记录")
                    }
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("历史")
                    }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
        
        // 请求通知权限
        NotificationManager.shared.requestAuthorization()
        
        return true
    }
    
    // 当应用在前台时收到通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 在前台也显示通知
        completionHandler([.banner, .sound])
    }
    
    // 处理通知点击事件
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 根据通知类型执行相应操作
        switch response.notification.request.identifier {
        case "morningDiary":
            NotificationCenter.default.post(name: NSNotification.Name("OpenMorningDiary"), object: nil)
        case "emotionRecord":
            NotificationCenter.default.post(name: NSNotification.Name("OpenEmotionRecord"), object: nil)
        case "nightDiary":
            NotificationCenter.default.post(name: NSNotification.Name("OpenNightDiary"), object: nil)
        default:
            break
        }
        completionHandler()
    }
}
