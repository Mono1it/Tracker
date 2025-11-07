import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var selectedDays: Set<WeekDay> = []
    
    //MARK: - Text Of UI Elements
    private let scheduleTitleText = NSLocalizedString("scheduleTitleText", comment: "")
    private let doneText = NSLocalizedString("doneText", comment: "")
    
    // MARK: - UI Elements
    private lazy var tableView = {
        let table = UITableView(frame: .zero, style: .plain)
        return table
    }()
    
    private lazy var scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = scheduleTitleText
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(doneText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupScheduleTitle()
        setupDoneButton()
        setupTableView()
    }
    
    //MARK: - Button Action
    @objc private func doneButtonTapped() {
        print("Кнопка 'Готово' нажата")
        delegate?.scheduleViewController(self, didSelectDays: Array(selectedDays))
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
        print("Выбранные дни: \(selectedDays.map { $0.title })")
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(scheduleTitleLabel, tableView, doneButton)
        view.backgroundColor = .ypWhite
    }
    
    private func setupScheduleTitle() {
        NSLayoutConstraint.activate([
            scheduleTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            scheduleTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
    }
    
    private func setupDoneButton() {
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        
        tableView.register(WeekDayCell.self, forCellReuseIdentifier: WeekDayCell.identifier)
        
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: scheduleTitleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
}
// MARK: - Extensions
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekDayCell.identifier, for: indexPath) as? WeekDayCell else {
            return UITableViewCell()
        }
        
        let day = WeekDay.allCases[indexPath.row]
        let isOn = selectedDays.contains(day)
        cell.configure(day: day, isOn: isOn)
        
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}



