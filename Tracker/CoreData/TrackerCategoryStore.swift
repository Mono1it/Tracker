import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent()
}

final class TrackerCategoryStore: NSObject {
    
    static let shared = TrackerCategoryStore()
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private override init() {}
    
    var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    // Найти сущность категории по title (если есть)
    func fetchCategoryEntity(withTitle title: String) -> TrackerCategoryCoreData? {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        req.fetchLimit = 1
        do {
            return try context.fetch(req).first
        } catch {
            print("❌ Ошибка при поиске категории: \(error)")
            return nil
        }
    }

    func addTrackerCategory(_ trackerCategory: TrackerCategory) {
        if let existingCategory = fetchCategoryEntity(withTitle: trackerCategory.title) {
            addTrackers(to: existingCategory, from: trackerCategory)
        } else {
            createNewCategory(with: trackerCategory)
        }
        saveContext()
    }

    private func addTrackers(to category: TrackerCategoryCoreData, from trackerCategory: TrackerCategory) {
        let existingTrackerIDs = (category.trackers as? Set<TrackerCoreData>)?.map { $0.id } ?? []
        for tracker in trackerCategory.trackers where !existingTrackerIDs.contains(tracker.id) {
            let trackerCD = createTrackerCoreData(from: tracker)
            trackerCD.category = category
            category.addToTrackers(trackerCD)
        }
    }

    private func createNewCategory(with trackerCategory: TrackerCategory) {
        let categoryCD = TrackerCategoryCoreData(context: context)
        categoryCD.title = trackerCategory.title
        for tracker in trackerCategory.trackers {
            let trackerCD = createTrackerCoreData(from: tracker)
            trackerCD.category = categoryCD
            categoryCD.addToTrackers(trackerCD)
        }
    }

    private func createTrackerCoreData(from tracker: Tracker) -> TrackerCoreData {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.id = tracker.id
        trackerCD.title = tracker.title
        trackerCD.emoji = tracker.emoji
        trackerCD.scheduleDays = tracker.schedule
        trackerCD.color = UIColorMarshalling.hexString(from: tracker.color) ?? "#FFFFFF"
        return trackerCD
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let result = try context.fetch(request)
        return result.map { category in
            let title = category.title ?? "Важное"
            
            let trackers: [Tracker] = (category.trackers as? Set<TrackerCoreData>)?.compactMap { tcd in
                guard let id = tcd.id,
                      let title = tcd.title
                else { return nil }
                
                let emoji = tcd.emoji ?? "🙂"
                let colorString = tcd.color ?? "#FFFFFF"
                let color = UIColorMarshalling.color(from: colorString) ?? UIColor(resource: .ypGray)
                
                let schedule = tcd.scheduleDays
                
                return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
            } ?? []
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    func startObservingChanges() {
        _ = fetchedResultsController
    }
    
    var categoriesObjects: [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.trackerCategoryStoreDidChangeContent()
        }
    }
}
