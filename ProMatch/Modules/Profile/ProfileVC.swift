import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    private var profileView: ProfileView { view as! ProfileView }
    override func loadView() { view = ProfileView() }
}
