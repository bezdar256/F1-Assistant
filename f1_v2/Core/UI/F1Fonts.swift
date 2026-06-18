import UIKit

enum F1Fonts {
    static func title(_ size: CGFloat = 34) -> UIFont { .systemFont(ofSize: size, weight: .black) }
    static func subtitle(_ size: CGFloat = 22) -> UIFont { .systemFont(ofSize: size, weight: .bold) }
    static func body(_ size: CGFloat = 15) -> UIFont { .systemFont(ofSize: size, weight: .medium) }
    static func caption(_ size: CGFloat = 12) -> UIFont { .systemFont(ofSize: size, weight: .semibold) }
    static func mono(_ size: CGFloat = 13) -> UIFont { .monospacedDigitSystemFont(ofSize: size, weight: .semibold) }
}
