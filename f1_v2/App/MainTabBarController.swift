import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        F1Theme.applyGlobalAppearance()
        view.backgroundColor = F1Colors.background
        tabBar.backgroundColor = F1Colors.surface
        tabBar.tintColor = F1Colors.primaryRed
        tabBar.unselectedItemTintColor = F1Colors.textSecondary
        tabBar.isTranslucent = false
        setViewControllers(makeTabs(), animated: false)
    }
    private func makeTabs() -> [UIViewController] {
        [
            makeNav(HomeViewController(), title: "F1 Assistant", icon: "house.fill"),
            makeNav(CalendarViewController(), title: "Race", icon: "calendar"),
            makeNav(LiveRaceViewController(), title: "Live", icon: "dot.radiowaves.left.and.right"),
            makeNav(DriversTeamsViewController(), title: "Drivers", icon: "person.2.fill"),
            makeNav(MoreViewController(), title: "More", icon: "ellipsis")
        ]
    }
    private func makeNav(_ root: UIViewController, title: String, icon: String) -> UINavigationController {
        root.title = title
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.tintColor = F1Colors.primaryRed
        nav.navigationBar.barTintColor = F1Colors.background
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: icon))
        return nav
    }
}
