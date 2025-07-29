import UIKit

class MainScreenViewController: UIViewController {
    //MARK: - Variables Of UI Elements
    private var trackerTitleText = "Трекеры"
    private var startQuestionText = "Что будем отслеживать?"
    private var searchbarPlaceholder = "Поиск"
    
    // MARK: - UI Elements
    lazy var trackerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = trackerTitleText
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    lazy var addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .addTrackerButton),
            target: nil,
            action: nil)
        button.tintColor = .ypBlack
        return button
    }()
    
    lazy var trackerDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        let localID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localID!)
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    lazy var starImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .star)
        return image
    }()
    
    lazy var startQuestion: UILabel = {
        let label = UILabel()
        label.text = startQuestionText
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
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
        setupStarImage()
        setupStartQuestion()
    }

    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(trackerTitleLabel, addTrackerButton, trackerDatePicker, starImage, startQuestion, searchBar)
        view.backgroundColor = .ypBackground
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
            trackerDatePicker.widthAnchor.constraint(equalToConstant: 97),
            trackerDatePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            trackerDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStarImage() {
        NSLayoutConstraint.activate([
            starImage.heightAnchor.constraint(equalToConstant: 80),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupStartQuestion() {
        NSLayoutConstraint.activate([
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
