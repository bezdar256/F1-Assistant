import UIKit

final class MoreViewController: BaseTableViewController, UITableViewDataSource {
    private let items: [(String, String, String, UIViewController)] = [
        ("Teams", "Constructor standings, cars and team form", "car.2.fill", TeamsViewController()),
        ("Analytics", "Driver comparison and season trends", "chart.bar.xaxis", AnalyticsViewController()),
        ("News", "Latest Formula 1 stories", "newspaper.fill", NewsViewController()),
        ("Profile & Settings", "Favorite driver, team and app preferences", "person.crop.circle.fill", SettingsViewController())
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More"
        tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
        cell.configure(title: item.0, subtitle: item.1, value: "OPEN", systemImage: item.2)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(items[indexPath.row].3, animated: true)
    }
}
