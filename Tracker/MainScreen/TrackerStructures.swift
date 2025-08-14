import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var name: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return "Пн."
        case .tuesday: return "Вт."
        case .wednesday: return "Ср."
        case .thursday: return "Чт."
        case .friday: return "Пт."
        case .saturday: return "Сб."
        case .sunday: return "Вс."
        }
    }
}
    struct TrackerCategory {
        let title: String
        let trackers: [Tracker]
    }
    
    struct TrackerRecord {
        let trackerId: UUID
        let date: String // формат "YYYY-MM-DD"
    }
