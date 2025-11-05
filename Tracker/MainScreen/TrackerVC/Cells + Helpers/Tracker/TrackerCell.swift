import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, in cell: TrackerCell)
    func uncompleteTracker(id: UUID, in cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    
    static let identifier = "TrackerCell"
    
    //MARK: - UI Elements
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGreen
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    lazy var emojiBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        return label
    }()
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        contentView.addSubviews(cardView, bottomView)
        cardView.addSubviews(emojiBackground, titleLabel)
        bottomView.addSubviews(daysLabel, plusButton)
        emojiBackground.addSubviews(emojiLabel)
        
        NSLayoutConstraint.activate([
            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            // Emoji background
            emojiBackground.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            //BottomView
            bottomView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 58),
            
            // Days label
            daysLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            
            // Plus button
            plusButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func trackButtonTapped() {
        guard let trackerId = trackerId else {
            assertionFailure("no trackerID")
            return
        }
        
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, in: self)
        } else {
            delegate?.completeTracker(id: trackerId, in: self)
        }
    }
    
    func configure(
        with tracker: Tracker,
        isComletedToday: Bool,
        comletedDays: Int
    ) {
        self.isCompletedToday = isComletedToday
        self.trackerId = tracker.id
        
        let color = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        
        daysLabel.text = "\(comletedDays) дней"
        
        cardView.backgroundColor = color
        plusButton.backgroundColor = isComletedToday ? color.withAlphaComponent(0.3) : color
        plusButton.setImage(UIImage(systemName: isComletedToday ? "checkmark" : "plus"), for: .normal)
    }
}
