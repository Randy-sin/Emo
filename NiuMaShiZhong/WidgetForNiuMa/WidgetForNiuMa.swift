//
//  WidgetForNiuMa.swift
//  WidgetForNiuMa
//
//  Created by Randy on 4/1/2025.
//

import WidgetKit
import SwiftUI

// 扩展 UserDefaults 以使用 App Group
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.randy.NiuMaShiZhong.shared")!
    static let workConfigKey = "WorkConfig"
    
    func loadWorkConfig() -> WorkConfig? {
        guard let data = UserDefaults.shared.object(forKey: Self.workConfigKey) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(WorkConfig.self, from: data)
    }
}

struct Provider: TimelineProvider {
    let defaultConfig = WorkConfig(
        monthlySalary: 0,
        workStartTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        workEndTime: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
        workSchedule: .fiveDay,
        joinDate: Date()
    )
    
    func placeholder(in context: Context) -> WorkEntry {
        WorkEntry(date: Date(), earnings: 0, timeUntilOff: (0, 0, 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkEntry) -> ()) {
        let workConfig = UserDefaults.shared.loadWorkConfig() ?? defaultConfig
        
        let entry = WorkEntry(
            date: Date(),
            earnings: workConfig.calculateTodayEarnings(),
            timeUntilOff: workConfig.calculateTimeUntilOff()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let workConfig = UserDefaults.shared.loadWorkConfig() ?? defaultConfig
        let currentDate = Date()
        var entries: [WorkEntry] = []
        
        // 减少更新频率，每5分钟更新一次，最多生成12个时间点（覆盖1小时）
        for minuteOffset in stride(from: 0, to: 60, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = WorkEntry(
                date: entryDate,
                earnings: workConfig.calculateTodayEarnings(),
                timeUntilOff: workConfig.calculateTimeUntilOff()
            )
            entries.append(entry)
        }

        // 设置在最后一个条目后5分钟更新
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: entries.last?.date ?? currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct WorkEntry: TimelineEntry {
    let date: Date
    let earnings: Double
    let timeUntilOff: (hours: Int, minutes: Int, seconds: Int)?
}

struct WidgetForNiuMaEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if family == .systemSmall {
                // 小尺寸布局
                VStack(spacing: 8) {
                    // 今日收益
                    VStack(spacing: 4) {
                        Text("today_earnings".localized)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("¥\(String(format: "%.2f", entry.earnings))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // 下班倒计时
                    VStack(spacing: 4) {
                        Text("time_until_off".localized)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if let timeLeft = entry.timeUntilOff {
                            HStack(spacing: 4) {
                                Text("\(timeLeft.hours)")
                                    .font(.system(size: 16, weight: .bold))
                                Text("hour".localized)
                                    .font(.system(size: 12))
                                Text("\(timeLeft.minutes)")
                                    .font(.system(size: 16, weight: .bold))
                                Text("minute".localized)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.primary)
                        } else {
                            Text("already_off".localized)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                }
            } else {
                // 中等尺寸布局
                HStack(spacing: 16) {
                    // 今日收益
                    VStack(spacing: 4) {
                        Text("today_earnings".localized)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("¥\(String(format: "%.2f", entry.earnings))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    // 下班倒计时
                    VStack(spacing: 4) {
                        Text("time_until_off".localized)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        if let timeLeft = entry.timeUntilOff {
                            HStack(spacing: 4) {
                                Text("\(timeLeft.hours)")
                                    .font(.system(size: 20, weight: .bold))
                                Text("hour".localized)
                                    .font(.system(size: 14))
                                Text("\(timeLeft.minutes)")
                                    .font(.system(size: 20, weight: .bold))
                                Text("minute".localized)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.primary)
                        } else {
                            Text("already_off".localized)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct WidgetForNiuMa: Widget {
    let kind: String = "WidgetForNiuMa"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetForNiuMaEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetForNiuMaEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("app_name".localized)
        .description("widget_description".localized)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WidgetForNiuMa()
} timeline: {
    WorkEntry(date: .now, earnings: 188.88, timeUntilOff: (2, 30, 0))
    WorkEntry(date: .now, earnings: 200.00, timeUntilOff: (2, 29, 0))
}
