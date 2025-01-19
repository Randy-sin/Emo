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
                
                DiaryView()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("日记")
                    }
                
                ReviewView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("回顾")
                    }
                
                // 添加新的页面
                ExploreView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("探索")
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
    
    // 处理 URL Scheme
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // 处理从 Widget 跳转
        if url.scheme == "emoease" {
            switch url.host {
            case "morning":
                // 发送通知以打开早安日记
                NotificationCenter.default.post(name: NSNotification.Name("OpenMorningDiary"), object: nil)
                return true
            case "emotion":
                // 发送通知以打开情绪记录
                NotificationCenter.default.post(name: NSNotification.Name("OpenEmotionRecord"), object: nil)
                return true
            case "night":
                // 发送通知以打开晚安日记
                NotificationCenter.default.post(name: NSNotification.Name("OpenNightDiary"), object: nil)
                return true
            default:
                return false
            }
        }
        return false
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

// 新的探索视图
struct Themediary: View {
    var body: some View {
        Text("探索页面")
    }
}