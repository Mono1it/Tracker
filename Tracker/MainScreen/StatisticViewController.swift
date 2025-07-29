import UIKit

final class StatisticViewController: UIViewController {
    // MARK: - UI Elements
    private let statisticTitleText: String = "Статистика"
    
    // MARK: - UI Elements
    lazy var statisticTitleLabel: UILabel = {
        let label = UILabel()
        label.text = statisticTitleText
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStatisticTitleLabel()
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(statisticTitleLabel)
        view.backgroundColor = .ypBackground
    }
    
    private func setupStatisticTitleLabel() {
        NSLayoutConstraint.activate([
            statisticTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -105)
        ])
    }
}
