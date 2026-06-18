import UIKit

final class LiveRaceViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = LiveRaceViewModel()
    private var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad(); title = "Live"; tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        tableView.register(LiveTimingCell.self, forCellReuseIdentifier: LiveTimingCell.reuseId)
        tableView.register(InfographicCell.self, forCellReuseIdentifier: InfographicCell.reuseId)
        tableView.refreshControl = UIRefreshControl(); tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
        if FavoritesStorage.shared.autoRefreshLive { timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in self?.load(false) } }
    }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); timer?.invalidate(); timer = nil }
    @objc private func refresh() { load(false) }
    private func load(_ loader: Bool = true) { if loader { showLoading("Loading race control…") }; Task { await viewModel.load(); await MainActor.run { self.title = self.viewModel.title; self.hideOverlay(); self.tableView.refreshControl?.endRefreshing(); self.tableView.reloadData() } } }
    func numberOfSections(in tableView: UITableView) -> Int { 4 }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { ["Session", "Live timing", "Infographics", "Race feed"][section] }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? 2 : section == 1 ? max(viewModel.rows.count, 1) : section == 2 ? (viewModel.rows.isEmpty ? 0 : 2) : max(viewModel.raceControl.count + viewModel.pitFeed.count, 1) }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if viewModel.rows.isEmpty {
                let c = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
                c.configure(title: "No timing rows yet", subtitle: "Timing data appears when OpenF1 publishes the session feed.", value: viewModel.statusValue, systemImage: "clock.fill")
                return c
            }
            let c = tableView.dequeueReusableCell(withIdentifier: LiveTimingCell.reuseId, for: indexPath) as! LiveTimingCell
            c.configure(viewModel.rows[indexPath.row])
            return c
        }
        if indexPath.section == 2 { let c = tableView.dequeueReusableCell(withIdentifier: InfographicCell.reuseId, for: indexPath) as! InfographicCell; c.configure(rows: viewModel.rows, mode: indexPath.row); return c }
        let c = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
        if indexPath.section == 0 { indexPath.row == 0 ? c.configure(title:viewModel.title, subtitle:viewModel.lapText, value:viewModel.statusValue, systemImage:"dot.radiowaves.left.and.right") : c.configure(title:"Track weather", subtitle:viewModel.weatherText, value:"DRY", systemImage:"cloud.sun.fill") }
        else {
            if viewModel.raceControl.isEmpty && viewModel.pitFeed.isEmpty {
                c.configure(title: "Race feed", subtitle: "Race control and pit updates will appear when session data is available.", value: viewModel.statusValue, systemImage: "flag.fill")
            } else if indexPath.row < viewModel.raceControl.count {
                let r = viewModel.raceControl[indexPath.row]
                c.configure(title:"LAP \(r.lap) • \(r.title)", subtitle:r.message, value:nil, systemImage:"flag.fill")
            } else {
                let p = viewModel.pitFeed[indexPath.row - viewModel.raceControl.count]
                c.configure(title:"LAP \(p.lap) • \(p.driver) pit stop", subtitle:p.change, value:p.duration, systemImage:"wrench.and.screwdriver.fill")
            }
        }
        return c
    }
}

final class InfographicCell: UITableViewCell {
    static let reuseId = "InfographicCell"
    private let card = F1CardView(); private let title = UILabel(); private let bar = BarChartView(); private let donut = DonutChartView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none
        contentView.addSubview(card); card.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        title.textColor = .white; title.font = F1Fonts.subtitle(18)
        card.addSubview(title); card.addSubview(bar); card.addSubview(donut)
        [title,bar,donut].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14), title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14), title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14), bar.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12), bar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14), bar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14), bar.heightAnchor.constraint(equalToConstant: 112), donut.centerXAnchor.constraint(equalTo: card.centerXAnchor), donut.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16), donut.widthAnchor.constraint(equalToConstant: 140), donut.heightAnchor.constraint(equalToConstant: 140), donut.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18), bar.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -18)])
    }
    func configure(rows: [LiveRow], mode: Int) { if mode == 0 { title.text = "Gap to leader"; bar.isHidden = false; donut.isHidden = true; bar.values = rows.prefix(5).map { ($0.code, max(1,$0.interval), TeamColors.color(for: $0.team)) } } else { title.text = "Tyre distribution"; bar.isHidden = true; donut.isHidden = false; let groups = Dictionary(grouping: rows, by: { $0.tyre }); donut.slices = groups.map { (Double($0.value.count), F1Colors.tyre($0.key)) } } }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
