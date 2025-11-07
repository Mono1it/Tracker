import UIKit

protocol HabitViewControllerDelegate: AnyObject {
    func habitViewController(_ controller: CreateHabitModalViewController, didCreate tracker: Tracker, inCategory category: String)
    func habitViewController(_ controller: CreateHabitModalViewController, didEdit tracker: Tracker, inCategory category: String)
}


final class CreateHabitModalViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate, DidSelectCategoryDelegate {
    
    weak var delegate: HabitViewControllerDelegate?
    weak var categoryDelegate: DidSelectCategoryDelegate?
    
    //MARK: - Tracker Elements
    private lazy var categoryTitle: String = ""
    private var trackerName: String?
    private var trackerEmoji: String?
    private var trackerColor: UIColor?
    private lazy var weekDaysForTracker: [WeekDay] = []
    private enum HabitCellType: CaseIterable {
        case category
        case schedule
    }
    private var editingTracker: Tracker?
    private var isEditingTracker: Bool { editingTracker != nil }
    private var completedDaysCount: Int = 0
    
    init(trackerToEdit: Tracker?, category: String) {
        super.init(nibName: nil, bundle: nil)
        self.editingTracker = trackerToEdit
        self.categoryTitle = category
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Text Of UI Elements
    private let trackerTitleText = NSLocalizedString("trackerTitleText_newHabit", comment: "")
    private let placeholder = NSLocalizedString("trackerPlaceholder", comment: "")
    private let limitText = NSLocalizedString("trackerLimitText", comment: "")
    private let limitLabelText: Int = 38
    private let cancelText = NSLocalizedString("cancelText", comment: "")
    private let createText = NSLocalizedString("createText", comment: "")
    private let emojiList: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    private let trackerColors: [UIColor] = (1...18).compactMap {
        UIColor(named: "Color Selection \($0)") //Очень чувствительная строка
    }
    private let headerNames: [String] = [
        NSLocalizedString("emojiHeader", comment: ""),
        NSLocalizedString("colorHeader", comment: "")
    ]
    
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    private var cells: [(type: HabitCellType, title: String, subtitle: String?)] = [
        (.category, NSLocalizedString("categoryCell", comment: ""), nil),
        (.schedule, NSLocalizedString("scheduleCell", comment: ""), nil)
    ]
    
    // MARK: - UI Elements
    private lazy var trackerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = trackerTitleText
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var completedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        return label
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
        field.clearButtonMode = .whileEditing
        return field
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
    
    private lazy var stackOfUIElements: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stackTextFieldView, tableView, collectionView])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private lazy var tableView = {
        let table = UITableView(frame: .zero, style: .plain)
        return table
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        return collection
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
    
    private let scrollView = UIScrollView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTrackerTitle()
        setupStackOfUIElements()
        setupStackButtons()
        
        if isEditingTracker {
            configureForEditing()
            completedDaysCount = TrackerRecordStore.shared.completedDaysCount(trackerId: editingTracker?.id ?? UUID())
            setupCompletedLabel()
        }
        completedLabel.isHidden = !isEditingTracker
    }
    
    //MARK: - Button Action
    @objc private func createButtonTapped() {
        print("Кнопка 'Создать' нажата")
        
        let id = editingTracker?.id ?? UUID()
        let tracker = Tracker(
            id: id,
            title: trackerName ?? "Трекер",
            color: trackerColor ?? UIColor(resource: .ypGray),
            emoji: trackerEmoji ?? "🙂",
            schedule: weekDaysForTracker
        )
        if isEditingTracker {
            delegate?.habitViewController(self, didEdit: tracker, inCategory: categoryTitle)
            
        } else {
            delegate?.habitViewController(self, didCreate: tracker, inCategory: categoryTitle)
            
        }
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
    
    private func openCreateScheduleModalWindow() {
        let modalVC = ScheduleViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    private func openCreateCategoryModalWindow() {
        let createCategoryVM = CategoryViewModel()
        let createCategoryVC = CategoryViewController(viewModel: createCategoryVM, selectedCategory: categoryTitle)
        createCategoryVC.categoryDelegate = self
        createCategoryVC.modalPresentationStyle = .automatic
        createCategoryVC.modalTransitionStyle = .coverVertical
        present(createCategoryVC, animated: true)
    }
    
    private func updateCreateButton() {
        let hasName = !(trackerName?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasSchedule = !weekDaysForTracker.isEmpty
        let hasEmoji = !(trackerEmoji?.isEmpty ?? true)
        let hasColor = trackerColor != UIColor.clear
        
        let isButtonEnabled = hasName && hasSchedule && hasEmoji && hasColor
        createButton.isEnabled = isButtonEnabled
        createButton.backgroundColor = isButtonEnabled ? .ypBlack : .ypGray
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(trackerTitleLabel, scrollView, completedLabel, stackButtons)
        view.backgroundColor = .ypWhite
    }
    
    private func setupCompletedLabel() {
        completedLabel.text = String(format: NSLocalizedString("completedDaysFormat", comment: ""), completedDaysCount)
        NSLayoutConstraint.activate([
            completedLabel.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 24),
            completedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completedLabel.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: -16)
        ])
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
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupTableView() {
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 500)    // Высота всей коллекции
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(HabitHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitHeader.identifier)
    }
    
    private func setupStackOfUIElements() {
        setupTextFieldView()
        setupTableView()
        setupCollectionView()
        
        scrollView.addSubview(stackOfUIElements)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackOfUIElements.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Констрейнты для scrollView
            scrollView.topAnchor.constraint(equalTo: isEditingTracker ? completedLabel.bottomAnchor : trackerTitleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackButtons.topAnchor, constant: -24),
            
            // Констрейнты для stackOfUIElements внутри scrollView
            stackOfUIElements.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackOfUIElements.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackOfUIElements.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackOfUIElements.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackOfUIElements.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
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
    
    private func configureForEditing() {
        trackerTitleLabel.text = NSLocalizedString("editTrackerTitle", comment: "")
        createButton.setTitle(NSLocalizedString("saveText", comment: ""), for: .normal)
        
        textField.text = editingTracker?.title
        trackerName = editingTracker?.title
        trackerEmoji = editingTracker?.emoji
        trackerColor = editingTracker?.color
        weekDaysForTracker = editingTracker?.schedule ?? []
        
        // Найдём индекс эмодзи и цвета
        if let emoji = editingTracker?.emoji,
           let emojiIndex = emojiList.firstIndex(of: emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
        }
        
        if let color = editingTracker?.color,
           let colorIndex = trackerColors.firstIndex(where: { $0 == color }) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 1)
        }
        
        // Подзаголовки
        cells[0].subtitle = categoryTitle
        let allDays = WeekDay.allCases
        if weekDaysForTracker.count == allDays.count {
            cells[1].subtitle = "Каждый день"
        } else {
            cells[1].subtitle = weekDaysForTracker.sorted { $0.rawValue < $1.rawValue }
                .map { $0.shortTitle }
                .joined(separator: " ")
        }
        
        tableView.reloadData()
        collectionView.reloadData()
        updateCreateButton()
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
            subtitle = NSLocalizedString("everyDay", comment: "")
        } else {
            // Сортируем по порядку из enum
            let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
            subtitle = sortedDays.map { $0.shortTitle }.joined(separator: " ")
        }
        
        updateCreateButton()
        cells[1].subtitle = subtitle.isEmpty ? nil : subtitle
        tableView.reloadData()
    }
    
    func didSelectCategory(category: String) {
        print("Выбранная категория: \(category)")
        categoryTitle = category
        let subtitle: String = category
        
        updateCreateButton()
        cells[0].subtitle = subtitle.isEmpty ? nil : subtitle
        tableView.reloadData()
    }
}

// MARK: - CreateHabitModalViewController extension
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
        
        let cellType = cells[indexPath.row].type
        print("Нажали на: \(cellType)")
        
        switch cellType {
        case .category:
            openCreateCategoryModalWindow()
        case .schedule:
            openCreateScheduleModalWindow()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75   // Высота ячейки таблицы
    }
}

// MARK: - CreateHabitModalViewController extension
extension CreateHabitModalViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2   // Количество секций в коллекции
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emojiList.count
        case 1:
            return trackerColors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            cell.configure(emoji: emojiList[indexPath.item])
            
            if let selectedEmojiIndex = selectedEmojiIndex, selectedEmojiIndex == indexPath {
                cell.selectCell(with: self.editingTracker?.emoji ?? "")
            } else {
                cell.deselectCell()
            }
            
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            cell.configure(color: trackerColors[indexPath.item])
            
            if let selectedColorIndex = selectedColorIndex, selectedColorIndex == indexPath {
                cell.selectCell(with: self.editingTracker?.color ?? .ypGray)
            } else {
                cell.deselectCell()
            }
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 2, bottom: 24, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HabitHeader.identifier,
            for: indexPath
        ) as? HabitHeader else { return UICollectionReusableView() }
        
        header.configure(with: headerNames[indexPath.section])
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let totalWidth = collectionView.bounds.width - 32
        let itemsPerRow = 6
        let totalSpacing = totalWidth - CGFloat(itemsPerRow) * 52
        return totalSpacing / CGFloat(itemsPerRow - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Минимальное расстояние между строками
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let previousSelection = selectedEmojiIndex {
                if let cell = collectionView.cellForItem(at: previousSelection) as? EmojiCell {
                    cell.deselectCell()
                    updateCreateButton()
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                cell.selectCell(with: emojiList[indexPath.item])
                updateCreateButton()
            }
            selectedEmojiIndex = indexPath
            self.trackerEmoji = emojiList[indexPath.item]
            
        case 1:
            if let previousSelection = selectedColorIndex {
                if let cell = collectionView.cellForItem(at: previousSelection) as? ColorCell {
                    cell.deselectCell()
                    updateCreateButton()
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.selectCell(with: trackerColors[indexPath.item])
                updateCreateButton()
            }
            selectedColorIndex = indexPath
            self.trackerColor = trackerColors[indexPath.item]
            
        default:
            break
        }
    }
}
