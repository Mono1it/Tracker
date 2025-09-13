import CoreData
import Foundation

final class TrackerRecordStore {
    
    private let context = CoreDataManager.shared.context
    
    func addTrackerRecord(_ record: TrackerRecord, tracker: TrackerCoreData) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = record.date
        
        trackerRecordCoreData.tracker = tracker
        CoreDataManager.shared.saveContext()
    }
}
