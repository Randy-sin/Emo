//
//  NiuMaShiZhongApp.swift
//  NiuMaShiZhong
//
//  Created by Randy on 3/1/2025.
//

import SwiftUI

@main
struct NiuMaShiZhongApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // 处理重启URL
        if let url = URLContexts.first?.url,
           url.scheme == "NiuMaShiZhong",
           url.host == "restart" {
            // 应用已经重启，不需要额外处理
        }
    }
}
