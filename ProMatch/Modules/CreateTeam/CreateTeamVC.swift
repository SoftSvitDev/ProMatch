import UIKit
import SnapKit

final class CreateTeamViewController: UIViewController {
    private var createTeamView: CreateTeamView { view as! CreateTeamView }

    override func loadView() { view = CreateTeamView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        createTeamView.navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        createTeamView.notesView.delegate = self
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension CreateTeamViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        createTeamView.notesPlaceholder.isHidden = !textView.text.isEmpty
    }
}
