import UIKit
import SnapKit
import PhotosUI

final class CreateTeamViewController: UIViewController {
    private var createTeamView: CreateTeamView { view as! CreateTeamView }
    private var pickedLogo: UIImage?

    override func loadView() { view = CreateTeamView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardAvoidance()
        enableKeyboardDismissal()
        createTeamView.navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        createTeamView.notesView.delegate = self
        createTeamView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)

        createTeamView.nameField.textField.addTarget(self, action: #selector(updateLogo), for: .editingChanged)
        createTeamView.nameField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        createTeamView.cityField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        createTeamView.foundedField.textField.addTarget(self, action: #selector(validateForm), for: .editingChanged)

        createTeamView.primarySwatchRow.onSelect = { [weak self] color in
            self?.createTeamView.logoView.backgroundColor = color
            self?.validateForm()
        }
        createTeamView.secondarySwatchRow.onSelect = { [weak self] _ in self?.validateForm() }

        createTeamView.logoView.addTarget(self, action: #selector(pickLogo), for: .touchUpInside)

        createTeamView.logoView.backgroundColor = createTeamView.primarySwatchRow.color
        updateLogo()
        validateForm()
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func updateLogo() {
        let name = createTeamView.nameField.textField.text ?? ""
        createTeamView.logoLabel.text = initials(from: name)
    }

    private func initials(from name: String) -> String {
        let words = name.split { !$0.isLetter }
        if words.isEmpty { return "" }
        if words.count == 1 { return words[0].prefix(2).uppercased() }
        return String(words[0].first!).uppercased() + String(words[1].first!).uppercased()
    }

    @objc private func validateForm() {
        let name = createTeamView.nameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let city = createTeamView.cityField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let valid = !name.isEmpty && !city.isEmpty
        createTeamView.saveButton.style = valid ? .primary : .disabled
    }

    @objc private func pickLogo() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func save() {
        let name = createTeamView.nameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let city = createTeamView.cityField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let foundedText = createTeamView.foundedField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let founded = Int(foundedText)
        let notes = createTeamView.notesView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let initialsText = initials(from: name)

        let primaryHex = hexValue(of: createTeamView.primarySwatchRow.color)
        let secondaryHex = hexValue(of: createTeamView.secondarySwatchRow.color)

        let teamId = UUID()
        var logoFilename: String? = nil
        if let logo = pickedLogo {
            logoFilename = DataStore.shared.saveTeamLogo(logo, for: teamId)
        }
        let team = Team(
            id: teamId,
            name: name,
            city: city,
            foundedYear: founded,
            initials: initialsText.isEmpty ? "T" : initialsText,
            primaryColorHex: primaryHex,
            secondaryColorHex: secondaryHex,
            players: [],
            notes: notes.isEmpty ? nil : notes,
            logoFilename: logoFilename
        )
        DataStore.shared.addTeam(team)
        close()
    }

    private func hexValue(of color: UIColor) -> UInt32 {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let R = UInt32(max(0, min(255, Int(r * 255))))
        let G = UInt32(max(0, min(255, Int(g * 255))))
        let B = UInt32(max(0, min(255, Int(b * 255))))
        return (R << 16) | (G << 8) | B
    }
}

extension CreateTeamViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        createTeamView.notesPlaceholder.isHidden = !textView.text.isEmpty
    }
}

extension CreateTeamViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let provider = result.itemProvider
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.pickedLogo = image
                self?.createTeamView.logoImageView.image = image
                self?.createTeamView.logoImageView.isHidden = false
                self?.createTeamView.logoLabel.isHidden = true
            }
        }
    }
}
