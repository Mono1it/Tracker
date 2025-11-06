import UIKit
import CoreData

final class StatisticViewController: UIViewController {
    // MARK: - UI Elements
    private let statisticTitleText: String = "Статистика"
    private let noDataText: String = "Анализировать пока нечего"
    
    // MARK: - UI Elements
    lazy var statisticTitleLabel: UILabel = {
        let label = UILabel()
        label.text = statisticTitleText
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var noDataImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .noData)
        return image
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = noDataText
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(statisticTitleLabel, noDataImage, noDataLabel)
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        setupStatisticTitleLabel()
        setupNoData()
    }
    
    private func setupStatisticTitleLabel() {
        NSLayoutConstraint.activate([
            statisticTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -105)
        ])
    }
    
    private func setupNoData() {
        NSLayoutConstraint.activate([
            noDataImage.heightAnchor.constraint(equalToConstant: 80),
            noDataImage.widthAnchor.constraint(equalToConstant: 80),
            noDataImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noDataImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            noDataLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noDataLabel.topAnchor.constraint(equalTo: noDataImage.bottomAnchor, constant: 8)
        ])
    }
}
