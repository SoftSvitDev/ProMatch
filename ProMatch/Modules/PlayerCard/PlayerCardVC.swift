import UIKit
import SnapKit

final class PlayerCardViewController: UIViewController {
    
    private var playerCardView: PlayerCardView {
        return view as! PlayerCardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = PlayerCardView()
    }
}

private extension PlayerCardViewController {
    
}
