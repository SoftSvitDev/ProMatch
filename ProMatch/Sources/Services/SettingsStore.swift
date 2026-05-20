import UIKit

extension Notification.Name {
    static let settingsDidChange = Notification.Name("SettingsStore.didChange")
}

final class SettingsStore {
    static let shared = SettingsStore()

    enum ThemeMode: String, CaseIterable {
        case system, light, dark
        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light Mode"
            case .dark: return "Dark Mode"
            }
        }
        var interfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .system: return .unspecified
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    private enum Keys {
        static let name = "settings.userName"
        static let theme = "settings.themeMode"
        static let notifications = "settings.notifications"
        static let formation = "settings.defaultFormation"
    }

    static let formations: [String] = ["4-3-3", "4-4-2", "4-2-3-1", "3-5-2", "3-4-3", "5-3-2", "4-5-1"]

    private let defaults = UserDefaults.standard
    private init() {}

    var userName: String {
        get { defaults.string(forKey: Keys.name) ?? "Coach" }
        set {
            defaults.set(newValue, forKey: Keys.name)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var themeMode: ThemeMode {
        get {
            if let raw = defaults.string(forKey: Keys.theme),
               let mode = ThemeMode(rawValue: raw) { return mode }
            return .dark
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.theme)
            applyTheme()
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var notificationsEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.notifications) == nil { return true }
            return defaults.bool(forKey: Keys.notifications)
        }
        set {
            defaults.set(newValue, forKey: Keys.notifications)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var defaultFormation: String {
        get { defaults.string(forKey: Keys.formation) ?? "4-3-3" }
        set {
            defaults.set(newValue, forKey: Keys.formation)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    func applyTheme() {
        let style = themeMode.interfaceStyle
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
