import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = makeRootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    private func makeRootViewController() -> UIViewController {
        let didCompleteOnboarding = UserDefaults.standard.bool(forKey: "onboarding_completed")
        if didCompleteOnboarding {
            return CustomTabBarViewController()
        }
        let onboarding = OnboardingViewController()
        onboarding.onFinish = { [weak self] in
            self?.transitionToMainApp()
        }
        return onboarding
    }

    private func transitionToMainApp() {
        guard let window else { return }
        let tabBar = CustomTabBarViewController()
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
            window.rootViewController = tabBar
        }
    }
}
