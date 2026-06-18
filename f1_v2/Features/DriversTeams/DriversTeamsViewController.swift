import UIKit

final class DriversTeamsViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = DriversTeamsViewModel()
    override func viewDidLoad() { super.viewDidLoad(); title = "Drivers"; tableView.dataSource = self; tableView.register(DriverCardCell.self, forCellReuseIdentifier: DriverCardCell.reuseId); load() }
    private func load() { showLoading("Loading driver cards…"); Task { await viewModel.load(); await MainActor.run { self.hideOverlay(); self.tableView.reloadData() } } }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.drivers.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { let c = tableView.dequeueReusableCell(withIdentifier: DriverCardCell.reuseId, for: indexPath) as! DriverCardCell; c.configure(viewModel.drivers[indexPath.row]); return c }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { navigationController?.pushViewController(DriverDetailViewController(driver: viewModel.drivers[indexPath.row]), animated: true) }
}
