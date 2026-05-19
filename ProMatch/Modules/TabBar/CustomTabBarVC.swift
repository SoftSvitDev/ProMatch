import UIKit
import SnapKit

final class CustomTabBarViewController: UIViewController {
    private let tabBar = CustomTabBarView(items: [
        .init(title: "Teams", symbol: "house"),
        .init(title: "Tournaments", symbol: "trophy"),
        .init(title: "Profile", symbol: "person"),
    ])
    
    private let contentContainer = UIView()
    
    private lazy var viewControllers: [UIViewController] = [
        UINavigationController(rootViewController: TeamsViewController()),
        UINavigationController(rootViewController: TournamentsViewController()),
        UINavigationController(rootViewController: ProfileViewController()),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        view.addSubview(contentContainer)
        view.addSubview(tabBar)
        
        viewControllers.forEach { vc in
            (vc as? UINavigationController)?.setNavigationBarHidden(true, animated: false)
        }
        
        contentContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tabBar.snp.top)
        }
        tabBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tabBar.onSelect = { [weak self] idx in
            self?.show(index: idx)
        }
        show(index: 0)
    }
    
    private func show(index: Int) {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        let vc = viewControllers[index]
        addChild(vc)
        contentContainer.addSubview(vc.view)
        vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        vc.didMove(toParent: self)
    }
}
