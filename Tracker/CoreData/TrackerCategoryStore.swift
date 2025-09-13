import CoreData
import Foundation

final class TrackerCategoryStore {
    
    private let context = CoreDataManager.shared.context
    private let trackerStore = TrackerStore()
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategory.title
        
        for tracker in trackerCategory.trackers {
            let trackerCoreData = trackerStore.addTracker(from: tracker)
            trackerCoreData.category = trackerCategoryCoreData
        }
        CoreDataManager.shared.saveContext()
    }
}
