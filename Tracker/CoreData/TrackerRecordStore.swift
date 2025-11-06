import CoreData
import Foundation

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChangeContent()
}

final class TrackerRecordStore: NSObject {
    
    static let shared = TrackerRecordStore()
    weak var delegate: TrackerRecordStoreDelegate?
    
    private override init() {}
    
    // MARK: - Core Data Context
    var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Core Data Methods
    enum TrackerRecordStoreError: Error {
        case cannotAddRecordInFuture
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData? = nil) throws {
        let recordDay = Calendar.current.startOfDay(for: trackerRecord.date)
        let todayDay  = Calendar.current.startOfDay(for: Date())
        
        guard recordDay <= todayDay else {
            throw TrackerRecordStoreError.cannotAddRecordInFuture
        }
        
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerRecord.trackerId
        record.date = trackerRecord.date
        if let t = tracker { record.tracker = t }
        saveContext()
    }
    
    func removeRecords(for trackerId: UUID, on date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let start = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
        
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@",
                                        trackerId as CVarArg, start as NSDate, nextDay as NSDate)
        
        do {
            let results = try context.fetch(request)
            for r in results { context.delete(r) }
            saveContext()
        } catch {
            print("❌ Ошибка удаления записей: \(error)")
        }
    }
    
    func removeAllRecords(for trackerId: UUID) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(request)
            for record in records {
                context.delete(record)
            }
            saveContext()
            print("🧹 Удалены все записи для трекера \(trackerId)")
        } catch {
            print("❌ Ошибка при удалении записей трекера: \(error)")
        }
    }
    
    func fetchTrackerRecords() throws -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let result = try context.fetch(request)
        return result.compactMap { coreDataRecord in
            guard let id = coreDataRecord.trackerId,
                  let date = coreDataRecord.date
            else { return nil }
            
            return TrackerRecord(trackerId: id, date: date)
        }
    }
    
    func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        request.resultType = .countResultType
        
        let start = Calendar.current.startOfDay(for: date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return false }
        
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@",
                                        trackerId as CVarArg, start as NSDate, nextDay as NSDate)
        do {
            let countResult = try context.count(for: request)
            return countResult > 0
        } catch {
            print("❌ Ошибка подсчёта записей: \(error)")
            return false
        }
    }
    
    func completedDaysCount(trackerId: UUID) -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            print("❌ Ошибка подсчёта completedDays: \(error)")
            return 0
        }
    }
    
    func countRecords() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        request.resultType = .countResultType
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            print("❌ Ошибка подсчёта countRecords: \(error)")
            return 0
        }
    }
    
    //MARK: - FetchedResultController
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        try? frc.performFetch()
        
        return frc
    }()
    
    func startObservingChanges() {
        _ = fetchedResultController
    }
}

//MARK: - FetchedResultControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.trackerRecordStoreDidChangeContent()
        }
    }
}
