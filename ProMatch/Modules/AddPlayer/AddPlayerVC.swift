import UIKit
import SnapKit

final class AddPlayerViewController: UIViewController {
    private var addPlayerView: AddPlayerView { view as! AddPlayerView }

    override func loadView() { view = AddPlayerView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerView.navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
