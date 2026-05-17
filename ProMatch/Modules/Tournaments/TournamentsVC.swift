import UIKit
import SnapKit

final class TournamentsViewController: UIViewController {
    
    private var tournamentsView: TournamentsView {
        return view as! TournamentsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = TournamentsView()
    }
}

private extension TournamentsViewController {
    
}
