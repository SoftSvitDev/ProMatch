import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = SettingsStore.shared.themeMode.interfaceStyle
        window.backgroundColor = Theme.Color.background

        let splash = SplashViewController()
        splash.onFinish = { [weak self] in
            self?.transitionToPostSplashRoot()
        }
        window.rootViewController = splash
        self.window = window
        window.makeKeyAndVisible()
    }

    private func transitionToPostSplashRoot() {
        guard let window, let current = window.rootViewController else { return }
        let next = makePostSplashRootViewController()
        swapRoot(window: window, oldVC: current, newVC: next)
    }

    private func makePostSplashRootViewController() -> UIViewController {
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
        guard let window, let current = window.rootViewController else { return }
        let tabBar = CustomTabBarViewController()
        swapRoot(window: window, oldVC: current, newVC: tabBar)
    }

    /// Swap the window's root with a clean fade.
    /// Sets the new root immediately, then overlays a snapshot of the previous root
    /// and animates it to alpha 0. This avoids the lighter mid-frame produced by
    /// `UIView.transition(.transitionCrossDissolve)` blending two semi-transparent views.
    private func swapRoot(window: UIWindow, oldVC: UIViewController, newVC: UIViewController) {
        let snapshot = oldVC.view.snapshotView(afterScreenUpdates: false)
        window.rootViewController = newVC
        guard let snapshot else { return }
        snapshot.frame = window.bounds
        snapshot.isUserInteractionEnabled = false
        window.addSubview(snapshot)
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { snapshot.alpha = 0 },
            completion: { _ in snapshot.removeFromSuperview() }
        )
    }
}
