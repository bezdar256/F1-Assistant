import UIKit

final class CalendarViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = CalendarViewModel()
    override func viewDidLoad() { super.viewDidLoad(); title = "Race Hub"; tableView.dataSource = self; tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId); tableView.register(RaceCardCell.self, forCellReuseIdentifier: RaceCardCell.reuseId); tableView.refreshControl = UIRefreshControl(); tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged); load() }
    @objc private func refresh() { load(false) }
    private func load(_ loader: Bool = true) { if loader { showLoading("Loading season calendar…") }; Task { await viewModel.load(); await MainActor.run { self.hideOverlay(); self.tableView.refreshControl?.endRefreshing(); self.tableView.reloadData() } } }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.races.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { let c = tableView.dequeueReusableCell(withIdentifier: RaceCardCell.reuseId, for: indexPath) as! RaceCardCell; c.configure(viewModel.races[indexPath.row]); return c }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { navigationController?.pushViewController(RaceDetailViewController(race: viewModel.races[indexPath.row]), animated: true) }
}

final class RaceCardCell: UITableViewCell {
    static let reuseId = "RaceCardCell"
    private let card = F1CardView(); private let photo = UIImageView(); private let track = UIImageView(); private let title = UILabel(); private let meta = UILabel(); private let badge = BadgeLabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none
        contentView.addSubview(card); card.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        photo.contentMode = .scaleAspectFill; photo.rounded(18); track.contentMode = .scaleAspectFit
        title.textColor = .white; title.font = F1Fonts.subtitle(20); title.numberOfLines = 2
        meta.textColor = F1Colors.textSecondary; meta.font = F1Fonts.body(13); meta.numberOfLines = 2
        card.addSubview(photo); card.addSubview(title); card.addSubview(meta); card.addSubview(track); card.addSubview(badge)
        [photo,title,meta,track,badge].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: card.topAnchor, constant: 12), photo.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12), photo.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12), photo.heightAnchor.constraint(equalToConstant: 120),
            title.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 12), title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14), title.trailingAnchor.constraint(equalTo: track.leadingAnchor, constant: -10),
            meta.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4), meta.leadingAnchor.constraint(equalTo: title.leadingAnchor), meta.trailingAnchor.constraint(equalTo: title.trailingAnchor), meta.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            track.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12), track.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12), track.widthAnchor.constraint(equalToConstant: 96), track.heightAnchor.constraint(equalToConstant: 70),
            badge.topAnchor.constraint(equalTo: photo.topAnchor, constant: 12), badge.leadingAnchor.constraint(equalTo: photo.leadingAnchor, constant: 12)
        ])
    }
    func configure(_ race: LocalRace) { let c = FallbackData.circuit(for: race.circuitId); photo.image = UIImage(named: c.photoName) ?? UIImage(named: "f1_hero"); track.image = UIImage(named: c.trackImageName) ?? UIImage(systemName: "map.fill"); title.text = "Round \(race.round) • \(race.title)"; meta.text = "\(c.city), \(c.country) • \(DateFormatterHelper.pretty(race.date))"; badge.text = "  \(race.status.uppercased())  "; badge.backgroundColor = race.status == "Completed" ? F1Colors.muted : F1Colors.primaryRed }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
