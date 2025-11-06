import UIKit
import CoreData

final class StatisticViewController: UIViewController {
    // MARK: - Data
    private let statisticTitleText = NSLocalizedString("statistics_title", comment: "Заголовок экрана статистики")
    private let noDataText = NSLocalizedString("no_data_text", comment: "Текст, когда нет данных для анализа")
    private lazy var stats: [(Int, String)] = []
    
    private let recordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    
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
    
    private lazy var statsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.isScrollEnabled = false
        return table
    }()
    
    //MARK: - Lifecylce
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPlaceHolderConditions()
        updateTrackerCountStatistic()
        statsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(statisticTitleLabel, noDataImage, noDataLabel, statsTableView)
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        setupStatisticTitleLabel()
        setupNoData()
        setupStatsTableView()
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
    
    private func setupStatsTableView() {
        statsTableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        NSLayoutConstraint.activate([
            statsTableView.topAnchor.constraint(equalTo: statisticTitleLabel.bottomAnchor, constant: 77),
            statsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Private Functions
    private func checkPlaceHolderConditions(){
        let isEmpty = recordStore.countRecords() == 0
        
        statsTableView.isHidden = isEmpty
        noDataImage.isHidden = !isEmpty
        noDataLabel.isHidden = !isEmpty
    }
    
    private func updateTrackerCountStatistic() {
        self.stats = [(
            recordStore.countRecords(),
            NSLocalizedString("trackers_completed", comment: "Количество завершённых трекеров")
        )]
    }
}

extension StatisticViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticCell.identifier, for: indexPath) as? StatisticCell else {
            return UITableViewCell()
        }
        let data = stats[indexPath.row]
        cell.configure(number: data.0, title: data.1)
        return cell
    }
}
