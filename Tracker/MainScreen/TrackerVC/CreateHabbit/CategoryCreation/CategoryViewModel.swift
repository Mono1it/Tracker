import Foundation

typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    // MARK: - Bindings
    var onCategoriesChanged: Binding<[TrackerCategoryCoreData]>?
    var onSelectedCategoryChanged: Binding<TrackerCategoryCoreData?>?
    var onEmptyStateChanged: Binding<Bool>?
    
    // MARK: - Data
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet { onCategoriesChanged?(categories) }
    }
    
    var selectedCategory: TrackerCategoryCoreData? {
        didSet { onSelectedCategoryChanged?(selectedCategory) }
    }
    
    // MARK: - Dependencies
    private let store = TrackerCategoryStore.shared
    
    init() {
        store.startObservingChanges()
    }
    
    // MARK: - Actions
    func loadCategories() {
        categories = store.categoriesObjects
        onEmptyStateChanged?(categories.isEmpty)
    }
    
    func addCategory(title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        store.addTrackerCategory(newCategory)
        loadCategories()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
    }
    
}
