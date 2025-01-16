import WidgetKit
import SwiftUI

struct EveningWidget: Widget {
    let kind: String = "EveningWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EveningProvider()) { entry in
            EveningWidgetView(entry: entry)
        }
        .configurationDisplayName("晚安日记")
        .description("记录一天的感悟")
        .supportedFamilies([.systemMedium])
    }
}

// 数据模型
struct EveningEntry: TimelineEntry {
    let date: Date
}

// 数据提供者
struct EveningProvider: TimelineProvider {
    func placeholder(in context: Context) -> EveningEntry {
        EveningEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (EveningEntry) -> ()) {
        let entry = EveningEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EveningEntry>) -> ()) {
        let entries = [EveningEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// Widget 视图
struct EveningWidgetView: View {
    var entry: EveningEntry
    
    var body: some View {
        ZStack {
            // 主要内容
            VStack(alignment: .leading, spacing: 0) {
                // 顶部问候语
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeGreeting)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.date.formatted(.dateTime.weekday()) + "，放松心情")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // 底部功能区 - 使用更现代的卡片设计
                HStack(spacing: 12) {
                    // 晚安日记按钮
                    Link(destination: URL(string: "emoease://night")!) {
                        HStack {
                            Color.clear
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image("moon_icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .offset(x: -5)
                                )
                            
                            Text("晚安日记")
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                // 背景图片
                Image("eveningwidget_resized")
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
    
    // 根据时间返回晚安相关的问候语
    var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: entry.date)
        switch hour {
        case 0..<6: return "夜深了，早点休息"
        case 6..<18: return "今天过得如何"
        case 18..<22: return "晚上好"
        default: return "该休息啦"
        }
    }
}

// Widget 预览
struct EveningWidget_Previews: PreviewProvider {
    static var previews: some View {
        EveningWidgetView(entry: EveningEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
} 