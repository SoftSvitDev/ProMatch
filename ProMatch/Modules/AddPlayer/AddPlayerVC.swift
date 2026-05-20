import UIKit
import SnapKit

final class AddPlayerViewController: UIViewController {
    private var addPlayerView: AddPlayerView { view as! AddPlayerView }
    private let presetTeamId: UUID?
    private var selectedTeamId: UUID?
    private var birthDate: Date?

    init(teamId: UUID? = nil) {
        self.presetTeamId = teamId
        self.selectedTeamId = teamId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = AddPlayerView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardAvoidance()
        enableKeyboardDismissal()
        addPlayerView.navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        addPlayerView.addButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        addPlayerView.firstNameField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        addPlayerView.lastNameField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        addPlayerView.positionGrid.onSelect = { [weak self] _ in self?.validateForm() }
        addPlayerView.birthFieldButton.addTarget(self, action: #selector(pickBirthDate), for: .touchUpInside)
        addPlayerView.teamFieldButton.addTarget(self, action: #selector(pickTeam), for: .touchUpInside)
        configureTeamPicker()
        validateForm()
    }

    private func configureTeamPicker() {
        // Disable picker when invoked from a specific team context (preset).
        let canChange = (presetTeamId == nil)
        addPlayerView.setTeamPickerEnabled(canChange)
        refreshTeamPickerLabel()
    }

    private func refreshTeamPickerLabel() {
        if let id = selectedTeamId, let team = DataStore.shared.team(id: id) {
            addPlayerView.teamFieldLabel.text = team.name
            addPlayerView.teamFieldLabel.textColor = Theme.Color.textPrimary
        } else {
            addPlayerView.teamFieldLabel.text = "Select team"
            addPlayerView.teamFieldLabel.textColor = Theme.Color.textTertiary
        }
    }

    @objc private func pickTeam() {
        let teams = DataStore.shared.teams
        guard !teams.isEmpty else { return }
        let sheet = UIAlertController(title: "Select team", message: nil, preferredStyle: .actionSheet)
        for team in teams {
            let isCurrent = team.id == selectedTeamId
            let title = isCurrent ? "\u{2713} \(team.name)" : team.name
            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedTeamId = team.id
                self?.refreshTeamPickerLabel()
                self?.validateForm()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = addPlayerView.teamFieldButton
            popover.sourceRect = addPlayerView.teamFieldButton.bounds
        }
        present(sheet, animated: true)
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
        let teamSelected = selectedTeamId != nil
        let valid = !first.isEmpty && !last.isEmpty && positionSelected && teamSelected
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
        guard let teamId = selectedTeamId else { return }
        let foot: Foot
        switch addPlayerView.footSegment.selectedIndex {
        case 0: foot = .left
        case 2: foot = .both
        default: foot = .right
        }
        let jersey = addPlayerView.jerseyStepper.value
        if let team = DataStore.shared.team(id: teamId),
           team.players.contains(where: { $0.jerseyNumber == jersey }) {
            let alert = UIAlertController(
                title: "Jersey #\(jersey) is taken",
                message: "Another player on this team already wears this number.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
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
