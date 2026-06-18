import UIKit
import SafariServices

final class HomeViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "F1 Assistant"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        tableView.register(DriverCardCell.self, forCellReuseIdentifier: DriverCardCell.reuseId)
        tableView.register(TeamCardCell.self, forCellReuseIdentifier: TeamCardCell.reuseId)
        refreshControlSetup()
        load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func refreshControlSetup() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = F1Colors.primaryRed
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc private func refresh() { load(false) }

    private func load(_ loader: Bool = true) {
        if loader { showLoading("Loading \(SeasonConfig.currentSeason) F1 season…") }
        Task {
            await viewModel.load()
            await MainActor.run {
                self.hideOverlay()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int { 7 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Next race", "Data source", "Weekend timeline", "Favorite driver", "Favorite team", "\(SeasonConfig.currentSeason) standings", "Latest stories"][section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2: return viewModel.nextRace.sessions.count
        case 5: return min(5, viewModel.topDrivers.count)
        case 6: return viewModel.news.count
        default: return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 260 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return heroCell(tableView)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(title: SeasonConfig.seasonTitle, subtitle: viewModel.sourceLabel, value: "LIVE", systemImage: "antenna.radiowaves.left.and.right")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            let session = viewModel.nextRace.sessions[indexPath.row]
            cell.configure(title: session.0, subtitle: session.1, value: session.2.uppercased(), systemImage: session.2 == "completed" ? "checkmark.circle.fill" : "clock.fill")
            return cell
        case 3:
            if let driver = viewModel.favoriteDriver {
                let cell = tableView.dequeueReusableCell(withIdentifier: DriverCardCell.reuseId, for: indexPath) as! DriverCardCell
                cell.configure(driver)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(title: "Choose your favorite driver", subtitle: "Open More → Profile and personalize the dashboard.", value: "SET", systemImage: "star.fill")
            return cell
        case 4:
            if let team = viewModel.favoriteTeam {
                let cell = tableView.dequeueReusableCell(withIdentifier: TeamCardCell.reuseId, for: indexPath) as! TeamCardCell
                cell.configure(team)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(title: "Choose your favorite team", subtitle: "Track team points, drivers and form directly on Home.", value: "SET", systemImage: "flag.2.crossed.fill")
            return cell
        case 5:
            let driver = viewModel.topDrivers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: DriverCardCell.reuseId, for: indexPath) as! DriverCardCell
            cell.configure(driver)
            return cell
        default:
            let news = viewModel.news[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(title: news.title, subtitle: "\(news.source) • \(news.summary)", value: news.date, systemImage: "newspaper.fill")
            return cell
        }
    }

    private func heroCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let hero = HeroImageView(imageName: viewModel.circuit.photoName)
        cell.contentView.addSubview(hero)
        hero.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        let badge = BadgeLabel(text: viewModel.nextRace.status, color: F1Colors.primaryRed)
        let title = UILabel()
        title.text = viewModel.nextRace.title
        title.textColor = .white
        title.font = F1Fonts.title(30)
        title.numberOfLines = 2

        let subtitle = UILabel()
        subtitle.text = "\(viewModel.circuit.name) • \(viewModel.circuit.country)"
        subtitle.textColor = F1Colors.textSecondary
        subtitle.font = F1Fonts.body(15)

        let countdown = UILabel()
        countdown.text = "\(SeasonConfig.currentSeason) race hub • \(DateFormatterHelper.pretty(viewModel.nextRace.date))"
        countdown.textColor = .white
        countdown.font = F1Fonts.mono(15)

        let track = UIImageView(image: UIImage(named: viewModel.circuit.trackImageName) ?? UIImage(systemName: "map.fill"))
        track.contentMode = .scaleAspectFit
        track.tintColor = .white

        let stack = UIStackView(axis: .vertical, spacing: 9)
        [badge, title, subtitle, countdown].forEach { stack.addArrangedSubview($0) }
        hero.addSubview(stack)
        hero.addSubview(track)
        stack.translatesAutoresizingMaskIntoConstraints = false
        track.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: track.leadingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -20),
            track.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -16),
            track.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -18),
            track.widthAnchor.constraint(equalToConstant: 115),
            track.heightAnchor.constraint(equalToConstant: 82)
        ])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            navigationController?.pushViewController(RaceDetailViewController(race: viewModel.nextRace), animated: true)
            return
        }

        if indexPath.section == 3 {
            navigationController?.pushViewController(SettingsViewController(focus: .driver), animated: true)
            return
        }

        if indexPath.section == 4 {
            navigationController?.pushViewController(SettingsViewController(focus: .team), animated: true)
            return
        }

        if indexPath.section == 6 {
            let article = viewModel.news[indexPath.row]
            guard let url = URL(string: article.url) else { return }
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = F1Colors.primaryRed
            present(safari, animated: true)
        }
    }
}
