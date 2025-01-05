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

// 添加主题颜色
struct ThemeColors {
    // 更深的背景色，进一步提高对比度
    static let darkBrown = Color(hex: "2B1810")  // 更深的棕色
    static let lightBrown = Color(hex: "5C2E1D")  // 中等深度的棕色
    // 更鲜艳的金色，增强视觉冲击
    static let goldColor = Color(hex: "FFD700")
    // 更柔和的强调色
    static let accentBrown = Color(hex: "FF8C42")  // 橙色调，增加活力
    // 文字颜色
    static let textLight = Color.white.opacity(0.95)  // 增加不透明度
    static let textSecondary = Color.white.opacity(0.85)  // 增加不透明度
    
    static let backgroundGradient = LinearGradient(
        colors: [darkBrown, lightBrown],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct WidgetForNiuMaEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    // 格式化金额，确保不会断行
    private func formatEarnings(_ value: Double) -> String {
        let formatted = String(format: "%.2f", value)
        return "¥\(formatted)"
    }

    // 格式化时间，使用国际化格式（小组件版本）
    private func formatTimeSmall(_ time: (hours: Int, minutes: Int, seconds: Int)) -> AttributedString {
        // 使用更紧凑的格式
        var result = AttributedString("\(time.hours)h\(time.minutes)m")
        
        // 使用更小的字体
        let baseFont = Font.system(size: 18, weight: .semibold, design: .rounded)
        let unitFont = Font.system(size: 14, weight: .semibold, design: .rounded)
        
        // 设置整体基础属性
        result.font = baseFont
        result.foregroundColor = ThemeColors.textLight
        
        // 设置数字部分的属性
        if let numberRange = result.range(of: "\(time.hours)") {
            result[numberRange].font = baseFont
        }
        if let minuteNumberRange = result.range(of: "\(time.minutes)") {
            result[minuteNumberRange].font = baseFont
        }
        
        // 设置单位部分的属性
        if let hRange = result.range(of: "h") {
            result[hRange].font = unitFont
        }
        if let mRange = result.range(of: "m") {
            result[mRange].font = unitFont
        }
        
        return result
    }
    
    // 为中等尺寸组件格式化时间（使用更大的字号）
    private func formatTimeMedium(_ time: (hours: Int, minutes: Int, seconds: Int)) -> AttributedString {
        // 使用空格分隔，更紧凑的格式
        var result = AttributedString("\(time.hours)h \(time.minutes)min")
        
        // 使用更合适的字体大小
        let baseFont = Font.system(size: 28, weight: .semibold, design: .rounded)
        let unitFont = Font.system(size: 24, weight: .semibold, design: .rounded)
        
        // 设置整体基础属性
        result.font = baseFont
        result.foregroundColor = ThemeColors.textLight
        
        // 设置数字部分的属性
        if let numberRange = result.range(of: "\(time.hours)") {
            result[numberRange].font = baseFont
        }
        if let minuteNumberRange = result.range(of: "\(time.minutes)") {
            result[minuteNumberRange].font = baseFont
        }
        
        // 设置单位部分的属性
        if let hRange = result.range(of: "h") {
            result[hRange].font = unitFont
        }
        if let minRange = result.range(of: "min") {
            result[minRange].font = unitFont
        }
        
        return result
    }

    var body: some View {
        Group {
            if family == .systemSmall {
                // 小尺寸布局
                VStack(spacing: 0) {
                    // 今日收益
                    VStack(spacing: 4) {
                        Text("today_earnings".localized)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        Text(formatEarnings(entry.earnings))
                            .font(.system(size: 26, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundColor(ThemeColors.goldColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    // 分隔线
                    Rectangle()
                        .fill(ThemeColors.textLight.opacity(0.15))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                    
                    // 下班倒计时
                    VStack(spacing: 4) {
                        Text("time_until_off".localized)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                            .padding(.top, 8)
                        
                        if let timeLeft = entry.timeUntilOff {
                            ZStack {
                                // 进度条背景
                                Capsule()
                                    .stroke(ThemeColors.textLight.opacity(0.08), lineWidth: 3)
                                    .frame(height: 28)  // 减小高度
                                
                                // 进度条
                                GeometryReader { geometry in
                                    Capsule()
                                        .trim(from: 0, to: calculateProgress(timeLeft))
                                        .stroke(
                                            LinearGradient(
                                                colors: [ThemeColors.accentBrown, ThemeColors.accentBrown.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                        )
                                        .frame(height: 28)  // 减小高度
                                }
                                
                                Text(formatTimeSmall(timeLeft))
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(height: 28)  // 减小高度
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                        } else {
                            Text("already_off".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textLight)
                                .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 12)
                .background(
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 100))
                        .foregroundColor(ThemeColors.textLight.opacity(0.02))
                        .rotationEffect(.degrees(-15))
                        .offset(y: 30)
                )
            } else {
                // 中尺寸布局
                HStack(spacing: 24) {
                    // 今日收益
                    VStack(spacing: 10) {
                        Text("today_earnings".localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        Text(formatEarnings(entry.earnings))
                            .font(.system(size: 38, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundColor(ThemeColors.goldColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 垂直分隔线
                    Rectangle()
                        .fill(ThemeColors.textLight.opacity(0.15))
                        .frame(width: 1)
                        .padding(.vertical, 20)
                    
                    // 下班倒计时
                    VStack(spacing: 10) {
                        Text("time_until_off".localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        if let timeLeft = entry.timeUntilOff {
                            Text(formatTimeMedium(timeLeft))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            // 时间进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(ThemeColors.textLight.opacity(0.08))
                                        .frame(height: 4)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [ThemeColors.accentBrown, ThemeColors.accentBrown.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * calculateProgress(timeLeft), height: 4)
                                }
                                .clipShape(Capsule())
                            }
                            .frame(height: 4)
                            .padding(.top, 8)
                        } else {
                            Text("already_off".localized)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(ThemeColors.textLight)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    HStack(spacing: 0) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 120))
                            .foregroundColor(ThemeColors.textLight.opacity(0.02))
                            .rotationEffect(.degrees(-15))
                            .offset(x: -40)
                        
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 120))
                            .foregroundColor(ThemeColors.textLight.opacity(0.02))
                            .rotationEffect(.degrees(15))
                            .offset(x: 40)
                    }
                )
            }
        }
    }
    
    // 计算时间进度
    private func calculateProgress(_ timeLeft: (hours: Int, minutes: Int, seconds: Int)) -> Double {
        let calendar = Calendar.current
        let workConfig = UserDefaults.shared.loadWorkConfig() ?? WorkConfig(
            monthlySalary: 0,
            workStartTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
            workEndTime: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
            workSchedule: .fiveDay,
            joinDate: Date()
        )
        
        // 计算工作总时长（分钟）
        let components = calendar.dateComponents([.hour, .minute], from: workConfig.workStartTime, to: workConfig.workEndTime)
        let totalMinutesInWorkday = Double((components.hour ?? 0) * 60 + (components.minute ?? 0))
        
        // 计算剩余时间（分钟）
        let remainingMinutes = Double(timeLeft.hours * 60 + timeLeft.minutes)
        
        return 1 - (remainingMinutes / totalMinutesInWorkday)
    }
}

// 添加颜色扩展
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

struct WidgetForNiuMa: Widget {
    let kind: String = "WidgetForNiuMa"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetForNiuMaEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    ThemeColors.backgroundGradient
                        .ignoresSafeArea()
                }
                .widgetURL(URL(string: "NiuMaShiZhong://widget-tap"))
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
