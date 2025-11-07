import CoreData
import Foundation

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChangeContent()
}

final class TrackerStore: NSObject {
    
    static let shared = TrackerStore()
    weak var delegate: TrackerStoreDelegate?
    
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
    enum TrackerStoreError: Error { case colorEncodingFailed; case colorDecodingFailed; case decodingFailed}
    
    func addTracker(from tracker: Tracker, category: TrackerCategoryCoreData? = nil) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.scheduleDays = tracker.schedule
        
        if let hex = UIColorMarshalling.hexString(from: tracker.color) {
            trackerCoreData.color = hex
        } else {
            trackerCoreData.color = "#FFFFFF"
            print("⚠️ UIColorMarshalling.hexString returned nil for \(tracker.title). Using fallback color.")
        }
        
        if let category = category {
            trackerCoreData.category = category
            category.addToTrackers(trackerCoreData)
        }
        
        saveContext()
    }
    
    func fetchTracker() throws -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        let result = try context.fetch(request)
        return try result.map { coreDataTracker in
            guard let id = coreDataTracker.id,
                  let title = coreDataTracker.title,
                  let emoji = coreDataTracker.emoji
            else { throw TrackerStoreError.decodingFailed }
            
            guard let colorString = coreDataTracker.color,
                  let trackerColor = UIColorMarshalling.color(from: colorString)
            else { throw TrackerStoreError.colorDecodingFailed }
            
            let schedule = coreDataTracker.scheduleDays
            
            return Tracker(id: id, title: title, color: trackerColor, emoji: emoji, schedule: schedule)
        }
    }
    
    //MARK: - FetchedResultController
    private lazy var fechedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true)
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
        _ = fechedResultsController
    }
}

//MARK: - FetchedResultControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.trackerStoreDidChangeContent()
        }
    }
}

// MARK: - ScheduleDays extension
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
