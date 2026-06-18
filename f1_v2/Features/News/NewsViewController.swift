import UIKit
import SafariServices

final class NewsViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = NewsViewModel()
    override func viewDidLoad() { super.viewDidLoad(); title = "News"; tableView.dataSource = self; tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId); load() }
    private func load() { showLoading("Loading paddock stories…"); Task { await viewModel.load(); await MainActor.run { self.hideOverlay(); self.tableView.reloadData() } } }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.news.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { let n=viewModel.news[indexPath.row]; let c=tableView.dequeueReusableCell(withIdentifier:InfoCardCell.reuseId, for:indexPath) as! InfoCardCell; c.configure(title:n.title, subtitle:"\(n.source) • \(n.summary)", value:n.date, systemImage:"newspaper.fill"); return c }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { guard let url=URL(string:viewModel.news[indexPath.row].url) else { return }; present(SFSafariViewController(url:url), animated:true) }
}
