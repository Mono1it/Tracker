import UIKit

class TrackersViewController: UIViewController, HabitViewControllerDelegate {
    //MARK: - Variables
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var trackerRecords: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    //MARK: - Variables Of UI Elements
    private var trackerTitleText = "Трекеры"
    private var startQuestionText = "Что будем отслеживать?"
    private var searchbarPlaceholder = "Поиск"
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var trackerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = trackerTitleText
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .addTrackerButton),
            target: nil,
            action: #selector(openCreateHabbitModalWindow))
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var trackerDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.clipsToBounds = true
        datePicker.calendar.firstWeekday = 2
        let localID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localID ?? "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var starImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .star)
        return image
    }()
    
    private lazy var startQuestion: UILabel = {
        let label = UILabel()
        label.text = startQuestionText
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var searchBarTextField: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.backgroundColor = .ypBackground
        searchBar.textColor = .ypBlack
        searchBar.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        searchBar.placeholder = searchbarPlaceholder
        
        searchBar.delegate = self
        
        return searchBar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        reloadData()
        
        TrackerStore.shared.delegate = self
        TrackerStore.shared.startObservingChanges()
        
        TrackerCategoryStore.shared.delegate = self
        TrackerCategoryStore.shared.startObservingChanges()
        
        TrackerRecordStore.shared.delegate = self
        TrackerRecordStore.shared.startObservingChanges()
        
        reloadAllDataFromStores()
    }
    
    private func reloadAllDataFromStores() {
        do {
            categories = try TrackerCategoryStore.shared.fetchCategories()
            trackerRecords = try TrackerRecordStore.shared.fetchTrackerRecords()
        } catch {
            print("❌ Ошибка при фетче из Core Data: \(error)")
        }

        reloadVisibleCategories()
    }
    
    // MARK: - Setup Functions
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.identifier
        )
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBarTextField.bottomAnchor, constant: 34),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -2)
        ])
    }
    
    private func setupUI() {
        view.addSubviews(trackerTitleLabel, addTrackerButton, trackerDatePicker, starImage, startQuestion, searchBarTextField, collectionView)
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        setupTrackerTitle()
        setupAddTrackerButton()
        setupTrackerDatePicker()
        setupSearchBar()
        setupStarQuestion()
        setupCollectionView()
    }
    
    private func setupTrackerTitle() {
        NSLayoutConstraint.activate([
            trackerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            trackerTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -105)
        ])
    }
    
    private func setupAddTrackerButton() {
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6)
        ])
    }
    
    private func setupTrackerDatePicker() {
        NSLayoutConstraint.activate([
            trackerDatePicker.heightAnchor.constraint(equalToConstant: 34),
            trackerDatePicker.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 77), // В фигме размер 77, но при таком размере дата отображается так: "12.12.2...."
            trackerDatePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            trackerDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStarQuestion() {
        NSLayoutConstraint.activate([
            starImage.heightAnchor.constraint(equalToConstant: 80),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            startQuestion.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startQuestion.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupSearchBar() {
        NSLayoutConstraint.activate([
            searchBarTextField.heightAnchor.constraint(equalToConstant: 36),
            searchBarTextField.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 7),
            searchBarTextField.leadingAnchor.constraint(equalTo: trackerTitleLabel.leadingAnchor),
            searchBarTextField.trailingAnchor.constraint(equalTo: trackerDatePicker.trailingAnchor)
        ])
    }
    
    // MARK: - Delegate Methods
    func habbitViewController(_ controller: CreateHabitModalViewController, didCreate tracker: Tracker, inCategory category: String) {
        // 1) если сущность категории уже есть в Core Data — добавим трекер туда
        if let categoryEntity = TrackerCategoryStore.shared.fetchCategoryEntity(withTitle: category) {
            TrackerStore.shared.addTracker(from: tracker, category: categoryEntity)
        } else {
            // 2) иначе создаём новую категорию вместе с трекером
            let dto = TrackerCategory(title: category, trackers: [tracker])
            TrackerCategoryStore.shared.addTrackerCategory(dto)
        }
        
        reloadAllDataFromStores()
        
        controller.dismiss(animated: true)
    }
    
    //MARK: - Button Action
    @objc private func openCreateHabbitModalWindow() {
        let modalVC = CreateHabitModalViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    @objc private func dateChanged() {
        reloadVisibleCategories()
    }
    
    //MARK: - Helpers
    private func reloadData() {
        dateChanged()
        reloadPlaceholder()
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: trackerDatePicker.date)
        let filterText = (searchBarTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter{ tracker in
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.numberValue == filterWeekday
                } == true
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)
                
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        collectionView.reloadData()
        reloadPlaceholder()
    }
    
    private func reloadPlaceholder() {
        let isEmpty = visibleCategories.isEmpty
        starImage.isHidden = !isEmpty
        startQuestion.isHidden = !isEmpty
    }
    
}

// MARK: - UITextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories()
        return true
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        reloadData()
        return visibleCategories[section].trackers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.identifier,
            for: indexPath
        ) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        
        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        
        let isCompletedToday = TrackerRecordStore.shared.isCompleted(trackerId: tracker.id, on: trackerDatePicker.date)
        let completedDays = TrackerRecordStore.shared.completedDaysCount(trackerId: tracker.id)

        
        cell.configure(
            with: tracker,
            isComletedToday: isCompletedToday,
            comletedDays: completedDays)
        
        cell.prepareForReuse()
        return cell
    }
}

//MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    
    func completeTracker(id: UUID, in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let trackerRecord = TrackerRecord(trackerId: id, date: trackerDatePicker.date)
        
        let today = Date()
        
        if trackerRecord.date > today {
            return
        }
        
        do {
            try TrackerRecordStore.shared.addNewTrackerRecord(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("❌ Нельзя добавить запись в будущем или произошла ошибка: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        TrackerRecordStore.shared.removeRecords(for: id, on: trackerDatePicker.date)
        
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidChangeContent() {
        DispatchQueue.main.async { [weak self] in
            self?.reloadAllDataFromStores()
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent() {
        DispatchQueue.main.async { [weak self] in
            self?.reloadAllDataFromStores()
        }
    }
}

//MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent() {
        do {
            trackerRecords = try TrackerRecordStore.shared.fetchTrackerRecords()
        } catch {
            print("❌ Ошибка при фетче записей: \(error)")
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
