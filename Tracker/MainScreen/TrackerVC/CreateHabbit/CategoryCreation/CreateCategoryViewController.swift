import UIKit

protocol CreateCategoryDelegate: AnyObject {
    func createCategoryViewController(_ controller: CreateCategoryViewController, didCreate category: String)
}

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryDelegate?
    
    //MARK: - Tracker Elements
    private var categotyName: String?
    
    //MARK: - Text Of UI Elements
    private let trackerTitleText = NSLocalizedString("newCategoryTitle", comment: "")
    private let placeholder = NSLocalizedString("categoryPlaceholder", comment: "")
    private let limitText = NSLocalizedString("categoryLimitText", comment: "")
    private let createText = NSLocalizedString("doneText", comment: "")
    private let limitLabelText: Int = 38
    
    // MARK: - UI Elements
    private lazy var createCategoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = trackerTitleText
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = limitText
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackTextFieldView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, limitLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(createText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTrackerTitle()
        setupTextFieldStack()
        setupCreateButton()
        updateCreateButton()
    }
    
    //MARK: - Button Action
    @objc private func createButtonTapped() {
        guard let categoryName = categotyName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryName.isEmpty else {
            return
        }
        
        delegate?.createCategoryViewController(self, didCreate: categoryName)
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.categotyName = textField.text ?? ""
        updateCreateButton()
    }
    
    private func updateCreateButton() {
        let hasName = !(categotyName?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        
        let isButtonEnabled = hasName
        createButton.isEnabled = isButtonEnabled
        createButton.backgroundColor = isButtonEnabled ? .ypBlack : .ypGray
    }
    
    //MARK: - Setup Functions
    private func setupTrackerTitle() {
        view.addSubview(createCategoryTitleLabel)
        NSLayoutConstraint.activate([
            createCategoryTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            createCategoryTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
    }
    
    private func setupTextFieldView() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupTextFieldStack() {
        setupTextFieldView()
        view.addSubview(stackTextFieldView)
        
        NSLayoutConstraint.activate([
            stackTextFieldView.topAnchor.constraint(equalTo: createCategoryTitleLabel.bottomAnchor, constant: 24),
            stackTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCreateButton() {
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
extension CreateCategoryViewController: UITextFieldDelegate {
    // MARK: - Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        limitLabel.isHidden = updatedText.count <= limitLabelText
        return updatedText.count <= limitLabelText
    }
}

