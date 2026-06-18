import UIKit

class BaseTableViewController: UIViewController, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var overlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = F1Colors.background
        tableView.backgroundColor = F1Colors.background
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        view.addSubview(tableView)
        tableView.pinToSuperview()
    }

    func showLoading(_ text: String = "Loading F1 data…") { showOverlay(LoadingView(text: text)) }
    func showEmpty(title: String, message: String) { showOverlay(EmptyStateView(title: title, message: message)) }
    func showError(_ error: Error) { showOverlay(EmptyStateView(title: "Data temporarily unavailable", message: "Please check your connection and try again.", systemImage: "wifi.exclamationmark")) }
    func hideOverlay() { overlay?.removeFromSuperview(); overlay = nil }
    private func showOverlay(_ view: UIView) { overlay?.removeFromSuperview(); overlay = view; self.view.addSubview(view); view.pinToSuperview() }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .white
        header.textLabel?.font = F1Fonts.subtitle(15)
        header.textLabel?.alpha = 0.95
    }
}

class BaseViewController: UIViewController {
    private var overlay: UIView?
    override func viewDidLoad() { super.viewDidLoad(); view.backgroundColor = F1Colors.background }
    func showLoading(_ text: String = "Loading F1 data…") { showOverlay(LoadingView(text: text)) }
    func showEmpty(title: String, message: String) { showOverlay(EmptyStateView(title: title, message: message)) }
    func hideOverlay() { overlay?.removeFromSuperview(); overlay = nil }
    private func showOverlay(_ view: UIView) { overlay?.removeFromSuperview(); overlay = view; self.view.addSubview(view); view.pinToSuperview() }
}
