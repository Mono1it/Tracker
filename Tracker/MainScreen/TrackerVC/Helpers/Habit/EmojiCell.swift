import UIKit

final class EmojiCell: UICollectionViewCell {
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()

    static let identifier = "EmojiCell"
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(emoji: String = "") {
        emojiLabel.text = emoji
    }
    
    func selectCell(with emoji: String) {
        contentView.backgroundColor = .ypLightGray
    }
    
    func deselectCell() {
        contentView.backgroundColor = .clear
    }
}
