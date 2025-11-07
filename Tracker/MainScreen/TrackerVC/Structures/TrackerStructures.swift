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
        case .monday: return NSLocalizedString("monday_full", comment: "")
        case .tuesday: return NSLocalizedString("tuesday_full", comment: "")
        case .wednesday: return NSLocalizedString("wednesday_full", comment: "")
        case .thursday: return NSLocalizedString("thursday_full", comment: "")
        case .friday: return NSLocalizedString("friday_full", comment: "")
        case .saturday: return NSLocalizedString("saturday_full", comment: "")
        case .sunday: return NSLocalizedString("sunday_full", comment: "")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return NSLocalizedString("monday_short", comment: "")
        case .tuesday: return NSLocalizedString("tuesday_short", comment: "")
        case .wednesday: return NSLocalizedString("wednesday_short", comment: "")
        case .thursday: return NSLocalizedString("thursday_short", comment: "")
        case .friday: return NSLocalizedString("friday_short", comment: "")
        case .saturday: return NSLocalizedString("saturday_short", comment: "")
        case .sunday: return NSLocalizedString("sunday_short", comment: "")
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
