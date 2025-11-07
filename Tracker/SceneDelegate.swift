import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func finishOnboard() {
        let onboardingVC = OnboardingScreenViewController()
        onboardingVC.onFinish = { [weak self] in
            guard let self else { return }
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self.window?.rootViewController = TabBarController()
        }
        window?.rootViewController = onboardingVC
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let onBoard: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if onBoard {
            window?.rootViewController = TabBarController()
        } else {
            finishOnboard()
        }
        window?.makeKeyAndVisible()
    }

}

