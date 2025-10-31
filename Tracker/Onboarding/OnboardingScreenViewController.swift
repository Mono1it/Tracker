import Foundation
import UIKit

class OnboardingScreenViewController: UIPageViewController {
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var pages: [UIViewController] = {
        let page1 = OnboardPageViewController(
            imageName: "OnboardBackground1",
            labelText: "Отслеживайте только то, что хотите"
        )
        
        let page2 = OnboardPageViewController(
            imageName: "OnboardBackground2",
            labelText: "Даже если это \nне литры воды и йога"
        )
        return [page1, page2]
    }()
    
    lazy var pageControll: UIPageControl = {
       let pageControll = UIPageControl()
        pageControll.numberOfPages = pages.count
        pageControll.currentPage = 0
        
        pageControll.currentPageIndicatorTintColor = .ypBlack
        pageControll.pageIndicatorTintColor = .ypGray
        
        pageControll.translatesAutoresizingMaskIntoConstraints = false
        return pageControll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        setupPageControll()
    }
    
    private func setupPageControll() {
        view.addSubview(pageControll)
        
        NSLayoutConstraint.activate([
            pageControll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControll.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingScreenViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        return previousIndex >= 0 ? pages[previousIndex] : pages.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        return nextIndex < pages.count ? pages[nextIndex] : pages.first
    }
}

extension OnboardingScreenViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControll.currentPage = currentIndex
        }
    }
}
