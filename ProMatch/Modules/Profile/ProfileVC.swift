import UIKit
import SnapKit
import StoreKit

final class ProfileViewController: UIViewController {
    private var profileView: ProfileView { view as! ProfileView }
    override func loadView() { view = ProfileView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .teamsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .tournamentsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .settingsDidChange, object: nil)

        profileView.editNameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        profileView.appearanceRow.addTarget(self, action: #selector(chooseAppearance), for: .touchUpInside)
        profileView.notificationsSwitch.addTarget(self, action: #selector(toggleNotifications), for: .valueChanged)
        profileView.rateUsRow.addTarget(self, action: #selector(rateUs), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    @objc private func refresh() {
        profileView.applyCounts(
            teams: DataStore.shared.teams.count,
            players: DataStore.shared.teams.reduce(0) { $0 + $1.players.count },
            tournaments: DataStore.shared.tournaments.count
        )
        profileView.applyUserName(SettingsStore.shared.userName)
        profileView.applyAppearance(SettingsStore.shared.themeMode.displayName)
        profileView.applyNotifications(enabled: SettingsStore.shared.notificationsEnabled)
    }

    @objc private func editName() {
        let alert = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Your name"
            tf.text = SettingsStore.shared.userName
            tf.autocapitalizationType = .words
            tf.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            guard !name.isEmpty else { return }
            SettingsStore.shared.userName = name
        })
        present(alert, animated: true)
    }

    @objc private func chooseAppearance() {
        let sheet = UIAlertController(title: "Appearance", message: nil, preferredStyle: .actionSheet)
        for mode in SettingsStore.ThemeMode.allCases {
            let isCurrent = mode == SettingsStore.shared.themeMode
            let title = isCurrent ? "✓ \(mode.displayName)" : mode.displayName
            sheet.addAction(UIAlertAction(title: title, style: .default) { _ in
                SettingsStore.shared.themeMode = mode
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func toggleNotifications(_ sender: UISwitch) {
        if sender.isOn {
            requestNotificationPermission { granted in
                if !granted {
                    sender.setOn(false, animated: true)
                    SettingsStore.shared.notificationsEnabled = false
                    self.showOpenSettingsAlert()
                } else {
                    SettingsStore.shared.notificationsEnabled = true
                }
            }
        } else {
            SettingsStore.shared.notificationsEnabled = false
        }
    }

    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                    completion(false)
                case .authorized, .provisional, .ephemeral:
                    completion(true)
                case .notDetermined:
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async { completion(granted) }
                    }
                @unknown default:
                    completion(false)
                }
            }
        }
    }

    private func showOpenSettingsAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Enable notifications in Settings to receive match reminders.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    @objc private func rateUs() {
        if let scene = view.window?.windowScene {
            AppStore.requestReview(in: scene)
        }
    }
}

private enum AppStore {
    static func requestReview(in scene: UIWindowScene) {
        if #available(iOS 18.0, *) {
            AppStore.requestReviewModern(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    @available(iOS 18.0, *)
    private static func requestReviewModern(in scene: UIWindowScene) {
        SKStoreReviewController.requestReview(in: scene)
    }
}

private extension UNNotificationSettings {}
