import Foundation

enum WorkSchedule: String, Codable {
    case fiveDay
    case sixDay
    case alternating
    
    var description: String {
        switch self {
        case .fiveDay:
            return "five_day_schedule".localized
        case .sixDay:
            return "six_day_schedule".localized
        case .alternating:
            return "alt_week_schedule".localized
        }
    }
} 