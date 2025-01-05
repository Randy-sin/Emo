import Foundation

// 添加币种枚举
enum Currency: String, Codable {
    case cny = "¥"
    case usd = "$"
}

struct WorkConfig: Codable, Equatable {
    var monthlySalary: Double
    var workStartTime: Date
    var workEndTime: Date
    var workSchedule: WorkSchedule
    var joinDate: Date
    var currency: Currency = .cny  // 添加币种属性，默认人民币
    
    // 添加 Equatable 实现
    static func == (lhs: WorkConfig, rhs: WorkConfig) -> Bool {
        return lhs.monthlySalary == rhs.monthlySalary &&
               lhs.workStartTime == rhs.workStartTime &&
               lhs.workEndTime == rhs.workEndTime &&
               lhs.workSchedule == rhs.workSchedule &&
               lhs.joinDate == rhs.joinDate
    }
    
    // 计算每月工作天数
    private var daysPerMonth: Double {
        switch workSchedule {
        case .fiveDay:
            return 5.0 * 4.33 // 双休：每周5天
        case .sixDay:
            return 6.0 * 4.33 // 单休：每周6天
        case .alternating:
            return 5.5 * 4.33 // 大小周：平均每周5.5天
        }
    }
    
    // 计算每天工作时长（小时）
    private var hoursPerDay: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: workStartTime, to: workEndTime)
        return Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60.0
    }
    
    // 计算秒薪
    private func calculateSecondRate() -> Double {
        return monthlySalary / (daysPerMonth * hoursPerDay * 3600)
    }
    
    // 获取工作时间范围
    private func getWorkTimeRange(for date: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: date)
        
        let workStart = calendar.date(bySettingHour: calendar.component(.hour, from: workStartTime),
                                    minute: calendar.component(.minute, from: workStartTime),
                                    second: 0,
                                    of: todayStart)!
        
        var workEnd = calendar.date(bySettingHour: calendar.component(.hour, from: workEndTime),
                                  minute: calendar.component(.minute, from: workEndTime),
                                  second: 0,
                                  of: todayStart)!
        
        // 如果结束时间小于开始时间，说明跨天了，需要加一天
        if workEnd <= workStart {
            workEnd = calendar.date(byAdding: .day, value: 1, to: workEnd)!
        }
        
        return (workStart, workEnd)
    }
    
    // 计算当天已赚金额
    func calculateTodayEarnings() -> Double {
        let now = Date()
        let calendar = Calendar.current
        let workTime = getWorkTimeRange()
        
        // 计算工作时长（秒）
        let workSeconds = calendar.dateComponents([.second], from: workTime.start, to: workTime.end).second ?? 0
        let workHours = Double(workSeconds) / 3600.0
        
        // 计算日薪（按工作日计算）
        let dailyRate = monthlySalary / daysPerMonth
        
        // 计算时薪
        let hourlyRate = dailyRate / workHours
        
        // 根据当前时间计算收入
        if now < workTime.start {
            // 未上班
            return 0.0
        } else if now >= workTime.end {
            // 已下班，返回全天工资
            return dailyRate
        } else {
            // 在工作时间内，按实际工作时长计算
            let workedSeconds = calendar.dateComponents([.second], from: workTime.start, to: now).second ?? 0
            let workedHours = Double(workedSeconds) / 3600.0
            return hourlyRate * workedHours
        }
    }
    
    // 计算本月累计收入
    func calculateMonthEarnings() -> Double {
        let now = Date()
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        // 计算本月已完成的工作天数
        let completedDays = countWorkdaysFromDate(start: monthStart, end: now)
        
        // 计算日薪
        let dailyRate = monthlySalary / daysPerMonth
        
        // 本月已完成天数的收入 + 今天实时收入
        return (dailyRate * Double(completedDays - 1)) + calculateTodayEarnings()
    }
    
    // 计算年度累计收入
    func calculateYearEarnings() -> Double {
        let now = Date()
        let calendar = Calendar.current
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
        
        // 计算已完成的月份数
        let completedMonths = calendar.dateComponents([.month], from: yearStart, to: now).month ?? 0
        
        // 已完成月份的收入
        let completedMonthsEarnings = monthlySalary * Double(completedMonths)
        
        // 本月收入
        let currentMonthEarnings = calculateMonthEarnings()
        
        return completedMonthsEarnings + currentMonthEarnings
    }
    
    // 计算距离下班还有多长时间
    func calculateTimeUntilOff() -> (hours: Int, minutes: Int, seconds: Int)? {
        let now = Date()
        let workTime = getWorkTimeRange()
        
        // 如果还没到上班时间或已经下班，返回nil
        if now < workTime.start || now >= workTime.end {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: workTime.end)
        return (components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }
    
    // 辅助方法：计算两个日期之间的工作日数量
    private func countWorkdaysFromDate(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        var date = start
        var workdays = 0
        
        while date <= end {
            let weekday = calendar.component(.weekday, from: date)
            let weekNumber = calendar.component(.weekOfYear, from: date)
            
            // 根据不同工作制度判断是否为工作日
            switch workSchedule {
            case .fiveDay:
                // 双休：周一至周五工作
                if weekday != 1 && weekday != 7 {
                    workdays += 1
                }
            case .sixDay:
                // 单休：只有周日休息
                if weekday != 1 {
                    workdays += 1
                }
            case .alternating:
                // 大小周：奇数周双休，偶数周单休
                if weekday != 1 { // 周日都休息
                    if weekNumber % 2 == 0 { // 偶数周（小周）
                        workdays += 1
                    } else if weekday != 7 { // 奇数周（大周）只有周日休息
                        workdays += 1
                    }
                }
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return workdays
    }
    
    // 计算从入职到现在的总收入
    func calculateTotalEarnings() -> Double {
        let now = Date()
        let calendar = Calendar.current
        
        // 计算完整工作天数（不包括今天）
        let completedDays = countWorkdaysFromDate(start: joinDate, end: calendar.startOfDay(for: now)) - 1
        
        // 计算日薪
        let dailyRate = monthlySalary / daysPerMonth
        
        // 完整工作日的收入
        let completedDaysEarnings = Double(completedDays) * dailyRate
        
        // 加上今天的实时收入
        let todayEarnings = calculateTodayEarnings()
        
        return completedDaysEarnings + todayEarnings
    }
} 