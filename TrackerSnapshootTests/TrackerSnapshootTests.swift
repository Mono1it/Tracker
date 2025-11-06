import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewControllerOnLightTheme() {
        let vc = TabBarController()
        vc.loadViewIfNeeded()
        vc.viewControllers?[0].loadViewIfNeeded()
        let listVC = vc.viewControllers?.first as? TrackersViewController
        listVC?.view.layoutIfNeeded()
        
        assertSnapshot(
            of: vc,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
            named: "light"
        )
    }
    
    func testViewControllerOnDarkTheme() {
        let vc = TabBarController()
        vc.overrideUserInterfaceStyle = .dark
        vc.loadViewIfNeeded()
        vc.viewControllers?[0].loadViewIfNeeded()
        let listVC = vc.viewControllers?.first as? TrackersViewController
        listVC?.view.layoutIfNeeded()
        
        assertSnapshot(
            of: vc,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
            named: "dark"
        )
    }
}
