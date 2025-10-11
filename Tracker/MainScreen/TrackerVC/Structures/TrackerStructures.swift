import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    func addTracker(_ tracker: Tracker) -> TrackerCategory {
        return TrackerCategory(title: title, trackers: trackers + [tracker])
    }
    
    func removeTracker(at index: Int) -> TrackerCategory {
        var newTrackers = trackers
        newTrackers.remove(at: index)
        return TrackerCategory(title: title, trackers: newTrackers)
    }
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}

enum WeekDay: Int, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
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
    
    var numberValue: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
    
    func weekday(from date: Date) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday
    }
}
