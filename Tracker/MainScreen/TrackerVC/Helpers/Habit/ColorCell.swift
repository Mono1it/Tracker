import UIKit

final class ColorCell: UICollectionViewCell {
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static let identifier = "ColorCell"
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(cellView)
        
        NSLayoutConstraint.activate([
            cellView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cellView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellView.heightAnchor.constraint(equalToConstant: 40),
            cellView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(color: UIColor = .clear) {
        cellView.backgroundColor = color
        
    }
    
    func selectCell(with color: UIColor) {
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func deselectCell() {
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
