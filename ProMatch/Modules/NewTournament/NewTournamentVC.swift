import UIKit
import SnapKit

final class NewTournamentViewController: UIViewController {
    
    private var newTournamentView: NewTournamentView {
        return view as! NewTournamentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = NewTournamentView()
    }
}

private extension NewTournamentViewController {
    
}
