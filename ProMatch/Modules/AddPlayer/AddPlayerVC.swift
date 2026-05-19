import UIKit
import SnapKit

final class AddPlayerViewController: UIViewController {
    private var addPlayerView: AddPlayerView { view as! AddPlayerView }
    private let teamId: UUID
    private var birthDate: Date?

    init(teamId: UUID) {
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = AddPlayerView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerView.navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        addPlayerView.addButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        addPlayerView.firstNameField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        addPlayerView.lastNameField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        addPlayerView.positionGrid.onSelect = { [weak self] _ in self?.validateForm() }
        addPlayerView.birthFieldButton.addTarget(self, action: #selector(pickBirthDate), for: .touchUpInside)
        validateForm()
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func validateForm() {
        let first = addPlayerView.firstNameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let last = addPlayerView.lastNameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let positionSelected = addPlayerView.positionGrid.selectedPosition != nil
        let valid = !first.isEmpty && !last.isEmpty && positionSelected
        addPlayerView.addButton.style = valid ? .primary : .disabled
    }

    @objc private func pickBirthDate() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()
        picker.date = birthDate ?? Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
        picker.overrideUserInterfaceStyle = .dark

        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 200),
        ])
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self else { return }
            self.birthDate = picker.date
            let f = DateFormatter(); f.dateStyle = .medium
            self.addPlayerView.birthFieldLabel.text = f.string(from: picker.date)
            self.addPlayerView.birthFieldLabel.textColor = Theme.Color.textPrimary
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func save() {
        let first = addPlayerView.firstNameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let last = addPlayerView.lastNameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let nickname = addPlayerView.nicknameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard let position = addPlayerView.positionGrid.selectedPosition else { return }
        let foot: Foot
        switch addPlayerView.footSegment.selectedIndex {
        case 0: foot = .left
        case 2: foot = .both
        default: foot = .right
        }
        let jersey = addPlayerView.jerseyStepper.value
        let height = Int(addPlayerView.heightField.textField.text ?? "")
        let weight = Int(addPlayerView.weightField.textField.text ?? "")

        let player = Player(
            firstName: first,
            lastName: last,
            nickname: nickname.isEmpty ? nil : nickname,
            jerseyNumber: jersey,
            position: position,
            preferredFoot: foot,
            birthDate: birthDate,
            heightCm: height,
            weightKg: weight
        )
        DataStore.shared.addPlayer(player, toTeam: teamId)
        close()
    }
}
