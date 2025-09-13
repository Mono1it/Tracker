import CoreData
import Foundation

final class TrackerStore {
    
    private let context = CoreDataManager.shared.context
    
    func addTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.scheduleDays = tracker.schedule
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color) ?? "#FFFFFF"
        
        CoreDataManager.shared.saveContext()
        return trackerCoreData
    }
}

extension TrackerCoreData {
    /// Удобная типобезопасная «обёртка» над transformable-атрибутом
    var scheduleDays: [WeekDay] {
        get {
            // Core Data вернёт уже раскодированный объект через трансформер
            return self.value(forKey: "schedule") as? [WeekDay] ?? []
        }
        set {
            // Передаём в Core Data исходное значение; трансформер сам закодирует
            self.setValue(newValue, forKey: "schedule")
        }
    }
}
