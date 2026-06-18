import UIKit

enum F1Theme {
    static func applyGlobalAppearance() {
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().tintColor = F1Colors.primaryRed
        UINavigationBar.appearance().barTintColor = F1Colors.background
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().tintColor = F1Colors.primaryRed
        UITabBar.appearance().unselectedItemTintColor = F1Colors.textSecondary
        UITabBar.appearance().barTintColor = F1Colors.surface
        UITabBar.appearance().backgroundColor = F1Colors.surface
    }
}
