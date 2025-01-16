//
//  EmoEaseWidget.swift
//  EmoEaseWidget
//
//  Created by Randy on 16/1/2025.
//

import WidgetKit
import SwiftUI

struct EmoEaseWidget: Widget {
    let kind: String = "EmoEaseWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("早安日记")
        .description("开启美好的一天")
        .supportedFamilies([.systemMedium])
    }
}

// 数据模型
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// 数据提供者
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// Widget 视图
struct WidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // 主要内容
            VStack(alignment: .leading, spacing: 0) {
                // 顶部问候语
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeGreeting)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.date.formatted(.dateTime.weekday()) + "，开启美好一天")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // 底部功能区 - 使用更现代的卡片设计
                HStack(spacing: 16) {
                    // 早安日记按钮
                    Link(destination: URL(string: "emoease://morning")!) {
                        HStack {
                            // 使用空视图占位，保持文字位置
                            Color.clear
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image("sun_icon_new")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32) // 更大的图标
                                        .offset(x: -5) // 微调位置
                                )
                            
                            Text("早安日记")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    
                    // 情绪记录按钮
                    Link(destination: URL(string: "emoease://emotion")!) {
                        HStack {
                            Color.clear
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image("alzheimer_icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .offset(x: -5)
                                )
                            
                            Text("记录心情")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                // 背景图片
                Image("widgetmorning_resized")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.9)
                
                // 更精致的渐变遮罩
                LinearGradient(
                    colors: [
                        .black.opacity(0.2),
                        .black.opacity(0.3),
                        .black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 额外添加一个整体遮罩
                Color.black.opacity(0.15)
            }
        }
    }
    
    // 根据时间返回早安相关的问候语
    var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: entry.date)
        switch hour {
        case 0..<6: return "早起的鸟儿有虫吃"
        case 6..<9: return "早安，美好的一天"
        case 9..<12: return "上午好"
        default: return "今天也要加油哦"
        }
    }
}

// Widget 预览
struct EmoEaseWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// 用于创建十六进制颜色的扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
