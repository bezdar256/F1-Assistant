import UIKit

enum F1Colors {
    static let background = UIColor(hex: "#05060A")
    static let surface = UIColor(hex: "#111318")
    static let card = UIColor(hex: "#171A21")
    static let cardSecondary = UIColor(hex: "#20242D")
    static let primaryRed = UIColor(hex: "#E10600")
    static let textPrimary = UIColor(hex: "#FFFFFF")
    static let textSecondary = UIColor(hex: "#A8ADB8")
    static let muted = UIColor(hex: "#6B7280")
    static let success = UIColor(hex: "#2ECC71")
    static let warning = UIColor(hex: "#F1C40F")
    static let blue = UIColor(hex: "#3498DB")

    static func tyre(_ compound: String) -> UIColor {
        switch compound.uppercased() {
        case "SOFT": return primaryRed
        case "MEDIUM": return warning
        case "HARD": return .white
        case "INTERMEDIATE": return success
        case "WET": return blue
        default: return muted
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
