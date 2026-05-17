import UIKit
import SnapKit

final class TeamsViewController: UIViewController {
    
    private var teamsView: TeamsView {
        return view as! TeamsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = TeamsView()
    }
}

private extension TeamsViewController {
    
}
