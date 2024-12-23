//
//  EmoEaseApp.swift
//  EmoEase
//
//  Created by Randy on 16/12/2024.
//

import SwiftUI

@main
struct EmoEaseApp: App {
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
