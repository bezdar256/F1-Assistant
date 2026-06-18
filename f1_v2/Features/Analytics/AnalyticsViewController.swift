import UIKit

final class AnalyticsViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = AnalyticsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Compare", style: .plain, target: self, action: #selector(openCompareMenu))
        load()
    }

    private func load() {
        showLoading("Loading season analytics…")
        Task {
            await viewModel.load()
            await MainActor.run {
                self.hideOverlay()
                self.tableView.reloadData()
            }
        }
    }

    @objc private func openCompareMenu() {
        let alert = UIAlertController(title: "Driver comparison", message: "Choose which driver to change.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Change first driver", style: .default) { _ in self.showDriverPicker(side: .left) })
        alert.addAction(UIAlertAction(title: "Change second driver", style: .default) { _ in self.showDriverPicker(side: .right) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private enum Side { case left, right }

    private func showDriverPicker(side: Side) {
        let title = side == .left ? "First driver" : "Second driver"
        let alert = UIAlertController(title: title, message: "Select a driver from the current standings.", preferredStyle: .actionSheet)
        for (index, driver) in viewModel.drivers.enumerated() {
            alert.addAction(UIAlertAction(title: "P\(driver.position)  \(driver.name)", style: .default) { _ in
                if side == .left { self.viewModel.selectLeft(index) }
                else { self.viewModel.selectRight(index) }
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Driver comparison" : "Constructor standings"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? comparisonRows().count : viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell

        if indexPath.section == 0 {
            let row = comparisonRows()[indexPath.row]
            cell.configure(title: row.title, subtitle: row.subtitle, value: nil, systemImage: row.icon)
        } else {
            let team = viewModel.teams[indexPath.row]
            let drivers = team.drivers.isEmpty ? "Drivers update from standings" : team.drivers.joined(separator: " / ")
            cell.configure(
                title: "P\(team.position)  \(team.name)",
                subtitle: drivers,
                value: "\(Int(team.points)) pts",
                systemImage: "chart.bar.fill"
            )
        }

        return cell
    }

    private func comparisonRows() -> [(title: String, subtitle: String, icon: String)] {
        let left = viewModel.left
        let right = viewModel.right
        return [
            (
                "Points",
                "\(left.code): \(Int(left.points))   vs   \(right.code): \(Int(right.points))",
                "number.circle.fill"
            ),
            (
                "Championship position",
                "\(left.code): P\(left.position)   vs   \(right.code): P\(right.position)",
                "list.number"
            ),
            (
                "Race wins",
                "\(left.code): \(left.wins)   vs   \(right.code): \(right.wins)",
                "flag.checkered"
            ),
            (
                "Teams",
                "\(left.code): \(left.team)   vs   \(right.code): \(right.team)",
                "person.2.fill"
            )
        ]
    }
}
