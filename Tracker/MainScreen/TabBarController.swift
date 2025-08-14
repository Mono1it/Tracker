import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainScreenVC = TrackersViewController()
        let statisticVC = StatisticViewController()
        
        mainScreenVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .circle),
            selectedImage: nil
        )
        
        statisticVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .rabbit),
            selectedImage: nil
        )
        
        viewControllers = [mainScreenVC, statisticVC]
        tabBar.addTopBorder(color: .ypGray, height: 0.5)
    }
    
}

extension UITabBar {
    func addTopBorder(color: UIColor = .lightGray, height: CGFloat = 1.0) {
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        self.layer.addSublayer(topBorder)
    }
}
