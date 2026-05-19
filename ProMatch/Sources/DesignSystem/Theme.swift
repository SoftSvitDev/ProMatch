import UIKit

enum Theme {
    enum Color {
        static let background = UIColor(hex: 0x0E0E10)
        static let surface = UIColor(hex: 0x1A1A20)
        static let surfaceElevated = UIColor(hex: 0x222229)
        static let inputBackground = UIColor(hex: 0x1F1F26)
        static let stroke = UIColor(hex: 0x2A2A2A)
        static let divider = UIColor(hex: 0x232329)

        static let accent = UIColor(hex: 0xC5F432)
        static let accentDim = UIColor(hex: 0x7A9020)

        static let textPrimary = UIColor.white
        static let textSecondary = UIColor(hex: 0xA0A0A8)
        static let textTertiary = UIColor(hex: 0x6B6B73)

        static let win = UIColor(hex: 0x22C55E)
        static let draw = UIColor(hex: 0xF59E0B)
        static let loss = UIColor(hex: 0xEF4444)

        static let pillRed = UIColor(hex: 0xEF4444)
        static let pillBlue = UIColor(hex: 0x3B82F6)
        static let pillGreen = UIColor(hex: 0x22C55E)
        static let pillOrange = UIColor(hex: 0xF97316)
        static let pillCyan = UIColor(hex: 0x06B6D4)
        static let pillPurple = UIColor(hex: 0x8B5CF6)
        static let pillYellow = UIColor(hex: 0xEAB308)
    }

    enum Font {
        static func bold(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func semibold(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        static func medium(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .medium)
        }
        static func regular(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }

    enum Metric {
        static let screenPadding: CGFloat = 24
        static let cardRadius: CGFloat = 16
        static let inputRadius: CGFloat = 12
        static let buttonRadius: CGFloat = 14
        static let buttonHeight: CGFloat = 52
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
