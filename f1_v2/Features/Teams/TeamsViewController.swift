import UIKit

final class TeamsViewController: BaseTableViewController, UITableViewDataSource {
    private let viewModel = TeamsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Teams"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TeamCardCell.self, forCellReuseIdentifier: TeamCardCell.reuseId)
        load()
    }

    private func load() {
        showLoading("Loading \(SeasonConfig.currentSeason) constructors…")
        Task {
            await viewModel.load()
            await MainActor.run {
                self.hideOverlay()
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.teams.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamCardCell.reuseId, for: indexPath) as! TeamCardCell
        cell.configure(viewModel.teams[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(TeamDetailViewController(team: viewModel.teams[indexPath.row]), animated: true)
    }
}

final class TeamsViewModel {
    private(set) var teams = FallbackData.teams.sorted { $0.position < $1.position }
    private let service = JolpicaService()

    func load() async {
        let driversResponse = try? await service.driverStandings()
        let constructorsResponse = try? await service.constructorStandings()
        var currentDrivers = FallbackData.drivers

        if let standings = driversResponse?.mrData.standingsTable?.standingsLists.first?.driverStandings, !standings.isEmpty {
            currentDrivers = standings.enumerated().map { F1DataMapper.localDriver(from: $0.element, index: $0.offset) }
        }

        if let constructors = constructorsResponse?.mrData.standingsTable?.standingsLists.first?.constructorStandings, !constructors.isEmpty {
            teams = constructors.enumerated().map { F1DataMapper.localTeam(from: $0.element, index: $0.offset, drivers: currentDrivers) }
        }
    }
}

final class TeamDetailViewController: BaseTableViewController, UITableViewDataSource {
    private let team: LocalTeam

    init(team: LocalTeam) {
        self.team = team
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = team.name
        tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(fav))
    }

    @objc private func fav() {
        FavoritesStorage.shared.favoriteTeamId = team.id
        navigationController?.popViewController(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Team", "\(SeasonConfig.currentSeason) constructor standings"][section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 1 ? 3 : 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 280 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = TeamCardCell(style: .default, reuseIdentifier: nil)
            cell.configure(team)
            return cell
        }

        let facts: [(String, String)]
        if team.position > 0 {
            facts = [
                ("Championship position", "P\(team.position)"),
                ("Points", "\(Int(team.points))"),
                ("Drivers", team.drivers.isEmpty ? "Updating from standings" : team.drivers.joined(separator: " / "))
            ]
        } else {
            facts = [
                ("Standings", "Updating"),
                ("Points", "Unavailable"),
                ("Drivers", team.drivers.isEmpty ? "Updating from standings" : team.drivers.joined(separator: " / "))
            ]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
        let fact = facts[indexPath.row]
        cell.configure(title: fact.0, subtitle: team.name, value: fact.1, systemImage: "flag.2.crossed.fill")
        return cell
    }
}
