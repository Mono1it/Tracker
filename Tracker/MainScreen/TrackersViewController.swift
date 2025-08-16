import UIKit

class TrackersViewController: UIViewController, HabbitViewControllerDelegate, TrackerCellDelegate {
    
    var trackersCategory: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    var trackerRecords: [UUID: Int] = [:] // Потом переделаю в TrackerRecord
    
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
        datePicker.minimumDate = Date()
        let localID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localID!)
        datePicker.preferredDatePickerStyle = .compact
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
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = UIColor(resource: .ypBackground)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = searchbarPlaceholder
        return searchBar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTrackerTitle()
        setupAddTrackerButton()
        setupTrackerDatePicker()
        setupSearchBar()
        setupStarQuestion()
        setupCollectionView()
        updateUI()
    }
    
    //MARK: - Button Action
    @objc private func openCreateHabbitModalWindow() {
        let modalVC = CreateHabbitModalViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
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
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -2)
        ])
    }
    
    private func setupUI() {
        view.addSubviews(trackerTitleLabel, addTrackerButton, trackerDatePicker, starImage, startQuestion, searchBar, collectionView)
        view.backgroundColor = .ypWhite
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
            searchBar.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    func updateUI() {
        let isEmpty = trackersCategory.isEmpty
        starImage.isHidden = !isEmpty
        startQuestion.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Delegate Methods
    func habbitViewController(_ controller: CreateHabbitModalViewController, didCreate tracker: Tracker, inCategory category: String) {
        if let index = trackersCategory.firstIndex(where: { $0.title == category }) {
            trackersCategory[index].trackers.append(tracker)
        } else {
            trackersCategory.append(TrackerCategory(title: category, trackers: [tracker]))
        }
        collectionView.reloadData()
        updateUI()
    }
    
    func didTapPlusButton(in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = trackersCategory[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = completedTrackers.contains(tracker.id)
        
        if isCompleted {
            // отменяем выполнение
            completedTrackers.remove(tracker.id)
            trackerRecords[tracker.id, default: 1] -= 1
        } else {
            // выполняем
            completedTrackers.insert(tracker.id)
            trackerRecords[tracker.id, default: 0] += 1
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
}

// MARK: - Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackersCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        updateUI()
        return trackersCategory[section].trackers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.identifier,
            for: indexPath
        ) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        
        header.configure(with: trackersCategory[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = trackersCategory[indexPath.section].trackers[indexPath.row]
        let days = trackerRecords[tracker.id] ?? 0
        let isCompleted = completedTrackers.contains(tracker.id)

        cell.delegate = self
        cell.configure(
            emoji: tracker.emoji,
            title: tracker.name,
            days: days,
            color: tracker.color,
            isCompleted: isCompleted
        )
        cell.prepareForReuse()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 148)
    }
}
