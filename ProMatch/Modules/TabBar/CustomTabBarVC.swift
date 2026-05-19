import UIKit
import SnapKit

final class CustomTabBarViewController: UIViewController {
    private let tabBar = CustomTabBarView(items: [
        .init(title: "Teams", symbol: "house"),
        .init(title: "Tournaments", symbol: "trophy"),
        .init(title: "Profile", symbol: "person"),
    ])

    private let contentContainer: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.background
        return v
    }()

    private var isTabBarHidden = false
    private var tabBarHeight: CGFloat = 0

    private lazy var viewControllers: [UINavigationController] = [
        UINavigationController(rootViewController: TeamsViewController()),
        UINavigationController(rootViewController: TournamentsViewController()),
        UINavigationController(rootViewController: ProfileViewController()),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        view.addSubview(contentContainer)
        view.addSubview(tabBar)

        viewControllers.forEach { nav in
            nav.setNavigationBarHidden(true, animated: false)
            nav.delegate = self
            nav.view.backgroundColor = Theme.Color.background
        }

        contentContainer.snp.makeConstraints { $0.edges.equalToSuperview() }
        tabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        tabBar.onSelect = { [weak self] idx in
            self?.show(index: idx)
        }
        show(index: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let h = tabBar.bounds.height
        if h > 0 && h != tabBarHeight {
            tabBarHeight = h
            // (Re)apply safe-area insets to all nav controllers now that we know height.
            for nav in viewControllers where !isTabBarHidden {
                nav.additionalSafeAreaInsets.bottom = h
            }
        }
    }

    private func show(index: Int) {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        let nav = viewControllers[index]
        addChild(nav)
        contentContainer.addSubview(nav.view)
        nav.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        nav.didMove(toParent: self)
        let shouldHide = nav.viewControllers.count > 1
        applyTabBarVisibility(hidden: shouldHide, on: nav, animated: false)
    }

    private func applyTabBarVisibility(hidden: Bool, on nav: UINavigationController, animated: Bool) {
        isTabBarHidden = hidden
        let height = tabBarHeight > 0 ? tabBarHeight : tabBar.bounds.height
        nav.additionalSafeAreaInsets.bottom = hidden ? 0 : height
        let block: () -> Void = {
            self.tabBar.transform = hidden ? CGAffineTransform(translationX: 0, y: height) : .identity
        }
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: block)
        } else {
            block()
        }
    }
}

extension CustomTabBarViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let isRoot = navigationController.viewControllers.first === viewController
        applyTabBarVisibility(hidden: !isRoot, on: navigationController, animated: animated)
    }
}
