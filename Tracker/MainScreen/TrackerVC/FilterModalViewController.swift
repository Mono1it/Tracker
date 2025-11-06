import UIKit

protocol DidSelectFilterDelegate: AnyObject {
    func didSelectFilter(filter: String)
}

enum filtersEnum: String {
    case all, today, complete, uncomplete
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("filterAll", comment: "")
        case .today: return NSLocalizedString("filterToday", comment: "")
        case .complete: return NSLocalizedString("filterComplete", comment: "")
        case .uncomplete: return NSLocalizedString("filterUncomplete", comment: "")
        }
    }
    
    var index: Int {
        switch self {
        case .all: return 0
        case .today: return 1
        case .complete: return 2
        case .uncomplete: return 3
        }
    }
}

final class FilterModalViewController: UIViewController {
    
    weak var delegate: DidSelectFilterDelegate?
    //MARK: - Data
    private var selectedFilter: String = ""
    private let filters: [filtersEnum] = [
        .all,
        .today,
        .complete,
        .uncomplete
    ]
    private var currentFilterIndex: Int = 0
    
    init(currentFilter: Int) {
        self.currentFilterIndex = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Text Of UI Elements
    private let categoryTitleText = NSLocalizedString("filterCategoryTitleText", comment: "")
    
    //MARK: - UIElements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = categoryTitleText
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.bounces = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupTableView()
        
    }
    
    //MARK: - Setup functions
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(filterTableView)
        
        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.isScrollEnabled = false
        
        filterTableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        
        filterTableView.layer.cornerRadius = 16
        filterTableView.layer.masksToBounds = true
        filterTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filterTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filterTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * filters.count))
        ])
    }
    
}

extension FilterModalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        
        let data = filters[indexPath.row]
        cell.configure(title: data.title)
        
        let checkmarkVisible = currentFilterIndex == data.index && data == .complete || currentFilterIndex == data.index && data == .uncomplete
        
        cell.accessoryType = checkmarkVisible ? .checkmark : .none
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = filters[indexPath.row].rawValue
        
        filterTableView.reloadData()
        delegate?.didSelectFilter(filter: data)
        print("Фильтр \(data) выбран")
        
        dismiss(animated: true)
    }
}
