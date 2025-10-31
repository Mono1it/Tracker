import Foundation
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    
}

protocol DidSelectCategoryDelegate: AnyObject {
    func didSelectCategory(category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var nameDelegate: CategoryViewControllerDelegate?
    weak var categoryDelegat: DidSelectCategoryDelegate?
    
    private var categoryName: String = ""
    private var categories: [TrackerCategoryCoreData] = []
    private var selectedCategory: TrackerCategoryCoreData?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    //MARK: - Text Of UI Elements
    private let categoryTitleText = "Категория"
    private let addButtonText = "Добавить категорию"
    private let startQuestionText = "Привычки и события можно \nобъединить по смыслу"
    
    //MARK: - UIElements
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = categoryTitleText
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var categoryTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.bounces = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle(addButtonText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var starImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .star)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var startQuestion: UILabel = {
        let label = UILabel()
        label.text = startQuestionText
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupAddButton()
        setupTableViewAndScrollView()
        setupStarQuestion()
        
        loadCategories()
        TrackerCategoryStore.shared.delegate = self
        TrackerCategoryStore.shared.startObservingChanges()
    }
    
    //MARK: - Selector actions
    @objc private func addButtonTapped() {
        let modalVC = CreateCategoryViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .automatic
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    //MARK: - Setup functions
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25)
        ])
    }
    
    private func setupTableViewAndScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(categoryTableView)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.isScrollEnabled = false
        
        categoryTableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.layer.masksToBounds = true
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // Высота таблицы
        tableViewHeightConstraint = categoryTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * categories.count))
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -30),
            
            // TableView
            categoryTableView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            categoryTableView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            categoryTableView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            categoryTableView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
        ])
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStarQuestion() {
        showStarLogo()
        view.addSubview(starImage)
        view.addSubview(startQuestion)
        
        NSLayoutConstraint.activate([
            starImage.heightAnchor.constraint(equalToConstant: 80),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            startQuestion.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startQuestion.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8)
        ])
    }
    
    //MARK: - Model
    private func showStarLogo() {
        let isEmpty = categories.isEmpty
        starImage.isHidden = !isEmpty
        startQuestion.isHidden = !isEmpty
    }
    
    private func loadCategories() {
        categories = TrackerCategoryStore.shared.categoriesObjects  // Загрузка из CoreData
        showStarLogo()
        categoryTableView.reloadData()
        updateTableViewHeight()
    }
    
    private func updateTableViewHeight() {
        tableViewHeightConstraint?.constant = CGFloat(75 * categories.count)  // Динамическая высота
        view.layoutIfNeeded()
    }
    
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        let isSelected = category.title == selectedCategory?.title
        cell.configure(title: category.title ?? "Без названия", isSelected: isSelected)  // Передаем флаг выбора
        
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryName = categories[indexPath.row]
        
        selectedCategory = categoryName // Для отображения галочки
        categoryTableView.reloadData()
        
        categoryDelegat?.didSelectCategory(category: categoryName.title ?? "Важное")
        print("Категория \(categoryName) выбрана")
        dismiss(animated: true)
    }
}

extension CategoryViewController: CreateCategoryDelegate {
    func createCategoryViewController(_ controller: CreateCategoryViewController, didCreate category: String) {
        
        let newTrackerCategory = TrackerCategory(title: category, trackers: [])
        TrackerCategoryStore.shared.addTrackerCategory(newTrackerCategory)
        
        dismiss(animated: true)
    }
}

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent() {
        DispatchQueue.main.async { [weak self] in
            self?.loadCategories()  // Автоматическое обновление при изменениях в CoreData
        }
    }
}
