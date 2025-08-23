import UIKit

protocol HabitViewControllerDelegate: AnyObject {
    func habbitViewController(_ controller: CreateHabitModalViewController, didCreate tracker: Tracker, inCategory category: String)
}

final class CreateHabitModalViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate {
    
    weak var delegate: HabitViewControllerDelegate?
    
    private let limitLabelText: Int = 38
    
    private lazy var categoryTitle: String = "Важное"
    private lazy var trackerName: String = "Трекер"
    private lazy var trackerColor: UIColor = .ypGreen
    private lazy var weekDaysForTracker: [WeekDay] = []
    
    //MARK: - Text Of UI Elements
    private let trackerTitleText = "Новая привычка"
    private let placeholder = "Введите название трекера"
    private let limitText = "Ограничение 38 символов"
    private let cancelText = "Отменить"
    private let createText = "Создать"
    
    // Данные для ячеек (title, subtitle)
    var cells: [(title: String, subtitle: String?)] = [
        ("Категория", "Важное"),
        ("Расписание", nil)
    ]
    
    // MARK: - UI Elements
    private lazy var tableView = {
        let table = UITableView(frame: .zero, style: .plain)
        return table
    }()
    
    private lazy var trackerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = trackerTitleText
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = limitText
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    private lazy var stackTextFieldView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, limitLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = placeholder
        field.backgroundColor = .ypBackground
        field.textAlignment = .left
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = true
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = padding
        field.leftViewMode = .always
        return field
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(cancelText, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        button.titleLabel?.textColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(createText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackButtons: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTrackerTitle()
        setupTextFieldView()
        setupTableView()
        setupStackButtons()
    }
    
    //MARK: - Button Action
    @objc private func createButtonTapped() {
        print("Кнопка 'Создать' нажата")
        let tracker = Tracker(
            id: UUID(),
            title: trackerName,
            color: trackerColor,
            emoji: "😪",
            schedule: weekDaysForTracker
        )
        delegate?.habbitViewController(self, didCreate: tracker, inCategory: categoryTitle)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        print("Кнопка 'Отменинь' нажата")
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.trackerName = textField.text ?? ""
        updateCreateButton()
    }
    
    private func openCreateHabbitModalWindow() {
        let modalVC = ScheduleViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    private func updateCreateButton() {
        let hasName = !(trackerName.trimmingCharacters(in: .whitespaces).isEmpty)
        let hasSchedule = !weekDaysForTracker.isEmpty
        
        if hasName && hasSchedule {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(trackerTitleLabel, stackTextFieldView, tableView, stackButtons)
        view.backgroundColor = .ypWhite
    }
    
    private func setupTrackerTitle() {
        NSLayoutConstraint.activate([
            trackerTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            trackerTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
    }
    
    private func setupTextFieldView() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            stackTextFieldView.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 38),
            stackTextFieldView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackTextFieldView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupStackButtons() {
        NSLayoutConstraint.activate([
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupTableView() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackTextFieldView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // MARK: - Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        limitLabel.isHidden = updatedText.count <= limitLabelText
        return updatedText.count <= limitLabelText
    }
    
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [WeekDay]) {
        print("Выбранные дни:", days)
        weekDaysForTracker = days
        let allDays = WeekDay.allCases
        let subtitle: String
        
        if days.count == allDays.count {
            subtitle = "Каждый день"
        } else {
            // Сортируем по порядку из enum
            let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
            subtitle = sortedDays.map { $0.shortTitle }.joined(separator: " ")
        }
        
        updateCreateButton()
        cells[1].subtitle = subtitle.isEmpty ? nil : subtitle
        tableView.reloadData()
    }
    
    // MARK: - Configure Methods
    private func configureTracker() -> TrackerCategory {
        TrackerCategory(title: categoryTitle, trackers: [Tracker(id: UUID(), title: trackerName, color: trackerColor, emoji: "😪", schedule: weekDaysForTracker)])
    }
}

// MARK: - Extensions
extension CreateHabitModalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        let data = cells[indexPath.row]
        cell.configure(title: data.title, subtitle: data.subtitle)
        
        cell.accessoryType = .disclosureIndicator // стрелочка справа
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Нажали на: \(cells[indexPath.row].title)")
        if cells[indexPath.row].title == "Расписание" {
            openCreateHabbitModalWindow()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
