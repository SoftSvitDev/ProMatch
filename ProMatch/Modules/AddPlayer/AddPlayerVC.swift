import UIKit
import SnapKit

final class AddPlayerViewController: UIViewController {
    
    private var addPlayerView: AddPlayerView {
        return view as! AddPlayerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = AddPlayerView()
    }
}

private extension AddPlayerViewController {
    
}
