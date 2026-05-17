import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    private var profileView: ProfileView {
        return view as! ProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = ProfileView()
    }
}

private extension ProfileViewController {
    
}
