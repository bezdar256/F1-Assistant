import UIKit

final class SettingsViewController: BaseTableViewController, UITableViewDataSource {
    enum FocusTarget { case driver, team }
    private enum Section: Int, CaseIterable { case driver, team, settings }

    private let service = JolpicaService()
    private let initialFocus: FocusTarget?
    private var didApplyInitialFocus = false

    private var drivers = FallbackData.drivers.sorted { $0.position < $1.position }
    private var teams = FallbackData.teams.sorted { $0.position < $1.position }

    init(focus: FocusTarget? = nil) {
        self.initialFocus = focus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Basic")
        loadCurrentOptions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyInitialFocusIfNeeded()
    }

    private func loadCurrentOptions() {
        Task {
            let driverResponse = try? await service.driverStandings()
            let constructorResponse = try? await service.constructorStandings()

            var liveDrivers = drivers
            if let standings = driverResponse?.mrData.standingsTable?.standingsLists.first?.driverStandings, !standings.isEmpty {
                liveDrivers = standings.enumerated().map { F1DataMapper.localDriver(from: $0.element, index: $0.offset) }
            }

            var liveTeams = teams
            if let constructors = constructorResponse?.mrData.standingsTable?.standingsLists.first?.constructorStandings, !constructors.isEmpty {
                liveTeams = constructors.enumerated().map { F1DataMapper.localTeam(from: $0.element, index: $0.offset, drivers: liveDrivers) }
            }

            await MainActor.run {
                self.drivers = liveDrivers
                self.teams = liveTeams
                self.tableView.reloadData()
                self.applyInitialFocusIfNeeded()
            }
        }
    }

    private func applyInitialFocusIfNeeded() {
        guard !didApplyInitialFocus, let initialFocus else { return }
        didApplyInitialFocus = true
        let section: Int = initialFocus == .team ? Section.team.rawValue : Section.driver.rawValue
        guard tableView.numberOfSections > section, tableView.numberOfRows(inSection: section) > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .driver: return "Favorite driver"
        case .team: return "Favorite team"
        case .settings: return "App settings"
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .driver: return drivers.count
        case .team: return teams.count
        case .settings: return 2
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .driver:
            let driver = drivers[indexPath.row]
            let selected = FavoritesStorage.shared.favoriteDriverId == driver.id
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(
                title: driver.name,
                subtitle: driver.position > 0 ? "P\(driver.position) • \(driver.team) • \(driver.nationality)" : "\(driver.team) • \(driver.nationality)",
                value: selected ? "SELECTED" : "SET",
                systemImage: selected ? "star.fill" : "person.fill"
            )
            return cell

        case .team:
            let team = teams[indexPath.row]
            let selected = FavoritesStorage.shared.favoriteTeamId == team.id
            let driversText = team.drivers.isEmpty ? "Drivers update with standings" : team.drivers.joined(separator: " / ")
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
            cell.configure(
                title: team.name,
                subtitle: team.position > 0 ? "P\(team.position) • \(Int(team.points)) pts • \(driversText)" : driversText,
                value: selected ? "SELECTED" : "SET",
                systemImage: selected ? "star.fill" : "flag.fill"
            )
            return cell

        case .settings:
            return settingsCell(indexPath.row)
        }
    }

    private func settingsCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = F1Colors.background
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = F1Colors.textSecondary
        cell.textLabel?.font = F1Fonts.body()
        cell.detailTextLabel?.font = F1Fonts.caption()

        if row == 0 {
            let sw = UISwitch()
            sw.onTintColor = F1Colors.primaryRed
            sw.isOn = FavoritesStorage.shared.autoRefreshLive
            sw.addTarget(self, action: #selector(toggleAutoRefresh(_:)), for: .valueChanged)
            cell.textLabel?.text = "Auto-refresh Live"
            cell.detailTextLabel?.text = "Refresh timing every 15 seconds"
            cell.accessoryView = sw
        } else {
            cell.textLabel?.text = "Reset favorites"
            cell.detailTextLabel?.text = "Clear selected driver and team"
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    @objc private func toggleAutoRefresh(_ sender: UISwitch) {
        FavoritesStorage.shared.autoRefreshLive = sender.isOn
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        switch section {
        case .driver:
            FavoritesStorage.shared.favoriteDriverId = drivers[indexPath.row].id
            tableView.reloadData()
        case .team:
            FavoritesStorage.shared.favoriteTeamId = teams[indexPath.row].id
            tableView.reloadData()
        case .settings:
            if indexPath.row == 1 {
                FavoritesStorage.shared.reset()
                tableView.reloadData()
            }
        }
    }
}
