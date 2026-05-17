import UIKit
import SnapKit

final class CreateTeamViewController: UIViewController {
    
    private var createTeamView: CreateTeamView {
        return view as! CreateTeamView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = CreateTeamView()
    }
}

private extension CreateTeamViewController {
    
}
