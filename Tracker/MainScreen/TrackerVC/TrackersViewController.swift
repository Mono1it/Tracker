import UIKit

final class TrackersViewController: UIViewController, HabitViewControllerDelegate, AlertPresenterDelegate {
    //MARK: - Variables
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var trackerRecords: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var currentFilter: filtersEnum = .all
    private var trackersOfDay: [Tracker] = []
    private lazy var alertPresenter = AlertPresenter(self)
    private let analyticsService = AnalyticsService()
    //MARK: - Variables Of UI Elements
    private var trackerTitleText = "Трекеры"
    private var startQuestionText = "Что будем отслеживать?"
    private var searchbarPlaceholder = "Поиск"
    private let filterText = "Фильтры"
    private let notFoundText = "Ничего не найдено"
    
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
            action: #selector(openCreateHabitModalWindow))
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(filterText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var notFoundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .notFound)
        return image
    }()
    
    private lazy var notFoundLabel: UILabel = {
        let label = UILabel()
        label.text = notFoundText
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.report(event: "open", screen: "main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: "close", screen: "main")
    }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let extraBottomInset: CGFloat = 50
        collectionView.contentInset.bottom = extraBottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = extraBottomInset
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
        view.addSubviews(trackerTitleLabel, addTrackerButton, trackerDatePicker, starImage, startQuestion, searchBarTextField, collectionView, filterButton, notFoundLabel, notFoundImage)
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        setupTrackerTitle()
        setupAddTrackerButton()
        setupTrackerDatePicker()
        setupSearchBar()
        setupStarQuestion()
        setupCollectionView()
        setupFilterButton()
        setupEmptyFilterPlaceholder()
    }
    
    private func setupEmptyFilterPlaceholder() {
        NSLayoutConstraint.activate([
            notFoundImage.heightAnchor.constraint(equalToConstant: 80),
            notFoundImage.widthAnchor.constraint(equalToConstant: 80),
            notFoundImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            notFoundImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            notFoundLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            notFoundLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupFilterButton() {
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17)
        ])
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
    func habitViewController(_ controller: CreateHabitModalViewController, didCreate tracker: Tracker, inCategory category: String) {
        if let categoryEntity = TrackerCategoryStore.shared.fetchCategoryEntity(withTitle: category) {
            TrackerStore.shared.addTracker(from: tracker, category: categoryEntity)
        } else {
            let dto = TrackerCategory(title: category, trackers: [tracker])
            TrackerCategoryStore.shared.addTrackerCategory(dto)
        }

        reloadAllDataFromStores()
        controller.dismiss(animated: true)
    }

    func habitViewController(_ controller: CreateHabitModalViewController, didEdit tracker: Tracker, inCategory category: String) {
        TrackerCategoryStore.shared.updateTracker(tracker, in: category)
        reloadAllDataFromStores()
        controller.dismiss(animated: true)
    }

    
    //MARK: - Button Action
    @objc private func openCreateHabitModalWindow() {
        analyticsService.report(event: "click", screen: "Main", item: "addTrack")
        let modalVC = CreateHabitModalViewController(trackerToEdit: nil, category: "")
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    @objc private func dateChanged() {
        analyticsService.report(event: "click", screen: "Main", item: "dateChanged")
        reloadVisibleCategories()
        reloadPlaceholder()
    }
    
    @objc private func filterButtonTapped() {
        analyticsService.report(event: "click", screen: "Main", item: "filter")
        let modalVC = FilterModalViewController(currentFilter: self.currentFilter.index)
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    //MARK: - Helpers
    private func reloadData() {
        dateChanged()
        reloadPlaceholder()
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: trackerDatePicker.date)
        
        trackersOfDay = categories.flatMap { $0.trackers }.filter { tracker in
            tracker.schedule.contains { $0.numberValue == filterWeekday }
        }
        
        let filterText = (searchBarTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter{ tracker in
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.numberValue == filterWeekday
                } == true
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)
                
                let isCompletedToday = TrackerRecordStore.shared.isCompleted(
                    trackerId: tracker.id,
                    on: trackerDatePicker.date
                )
                
                let filterCondition: Bool
                switch currentFilter {
                case .all, .today:
                    filterCondition = true
                case .complete:
                    filterCondition = isCompletedToday
                case .uncomplete:
                    filterCondition = !isCompletedToday
                }
                
                return textCondition && dateCondition && filterCondition
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
        let noTrackersAtAll = trackersOfDay.isEmpty
        
        let filterGaveNothing = !noTrackersAtAll && visibleCategories.isEmpty
        
        if noTrackersAtAll {
            // Показываем "Что будем отслеживать?"
            starImage.isHidden = false
            startQuestion.isHidden = false
            notFoundImage.isHidden = true
            notFoundLabel.isHidden = true
            collectionView.isHidden = true
            filterButton.isHidden = true
            return
        }
        
        if filterGaveNothing {
            // Показываем "Ничего не найдено"
            starImage.isHidden = true
            startQuestion.isHidden = true
            notFoundImage.isHidden = false
            notFoundLabel.isHidden = false
            collectionView.isHidden = true
            filterButton.isHidden = false
            return
        }
        
        // Есть что показать
        starImage.isHidden = true
        startQuestion.isHidden = true
        notFoundImage.isHidden = true
        notFoundLabel.isHidden = true
        collectionView.isHidden = false
        filterButton.isHidden = false
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        analyticsService.report(event: "click", screen: "Main", item: "openContext")
        print("Окно контекста показано")
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self else { return }
                    analyticsService.report(event: "click", screen: "Main", item: "editTracker")
                        let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
                        let category = self.visibleCategories[indexPath.section].title

                        let editVC = CreateHabitModalViewController(trackerToEdit: tracker, category: category)
                        editVC.delegate = self
                        editVC.modalPresentationStyle = .automatic
                        editVC.modalTransitionStyle = .coverVertical
                        self.present(editVC, animated: true)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    analyticsService.report(event: "click", screen: "Main", item: "deleteTracker")
                    let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
                        
                        let alertModel = AlertModel(
                            title: "",
                            message: "Уверены, что хотите удалить трекер?",
                            buttonText: "Удалить"
                        ) { [weak self] in
                            guard let self = self else { return }

                            // Удаляем записи трекера
                            TrackerRecordStore.shared.removeAllRecords(for: tracker.id)

                            // Удаляем сам трекер
                            TrackerCategoryStore.shared.removeTracker(tracker.id)

                            self.reloadAllDataFromStores()
                        }

                        self.alertPresenter.requestAlertPresenter(model: alertModel)
                }
            ])
        })
    }
    func didAlertButtonTouch(alert: UIAlertController?) {
        print("Трекер удалён")
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
            analyticsService.report(event: "click", screen: "Main", item: "completeTracker")
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("❌ Нельзя добавить запись в будущем или произошла ошибка: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        TrackerRecordStore.shared.removeRecords(for: id, on: trackerDatePicker.date)
        analyticsService.report(event: "click", screen: "Main", item: "uncompleteTracker")
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
            self.reloadPlaceholder()
        }
    }
}

extension TrackersViewController: DidSelectFilterDelegate {
    func didSelectFilter(filter: String) {
        guard let newFilter = filtersEnum(rawValue: filter) else { return }
        currentFilter = newFilter
        
        if newFilter == .today {
            trackerDatePicker.date = Date()   // переключаем календарь на сегодня
        }
        
        reloadVisibleCategories()
    }
}
