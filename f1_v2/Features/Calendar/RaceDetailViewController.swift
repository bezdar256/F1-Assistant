import UIKit

final class RaceDetailViewController: BaseTableViewController, UITableViewDataSource {
    private let race: LocalRace
    private let service = JolpicaService()
    private var raceResults: [RaceResult] = []
    private var qualifyingResults: [QualifyingResult] = []
    private var circuit: LocalCircuit { FallbackData.circuit(for: race.circuitId) }

    private var sections: [String] {
        var result = ["Circuit"]
        if !raceResults.isEmpty { result.append("Race summary") }
        if !raceResults.isEmpty { result.append("Race result") }
        if !qualifyingResults.isEmpty { result.append("Qualifying") }
        result.append("Weekend schedule")
        result.append("Track facts")
        return result
    }

    init(race: LocalRace) {
        self.race = race
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = race.title
        tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        loadSessionData()
    }

    private func loadSessionData() {
        Task {
            async let resultsTask = try? service.raceResults(round: String(race.round))
            async let qualifyingTask = try? service.qualifying(round: String(race.round))

            let resultResponse = await resultsTask
            let qualifyingResponse = await qualifyingTask

            await MainActor.run {
                self.raceResults = resultResponse?.mrData.raceTable.races.first?.results ?? []
                self.qualifyingResults = qualifyingResponse?.mrData.raceTable.races.first?.qualifyingResults ?? []
                self.tableView.reloadData()
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case "Circuit": return 1
        case "Race summary": return min(3, raceResults.count)
        case "Race result": return min(10, raceResults.count)
        case "Qualifying": return min(10, qualifyingResults.count)
        case "Weekend schedule": return race.sessions.count
        case "Track facts": return trackFacts().count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        sections[indexPath.section] == "Circuit" ? 310 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if section == "Circuit" { return circuitHeroCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell

        switch section {
        case "Race summary":
            let result = raceResults[indexPath.row]
            let labels = ["Winner", "Second", "Third"]
            cell.configure(
                title: labels[indexPath.row],
                subtitle: "\(result.driver.fullName) • \(result.constructor.name)",
                value: result.time?.time ?? result.status,
                systemImage: indexPath.row == 0 ? "trophy.fill" : "medal.fill"
            )

        case "Race result":
            let result = raceResults[indexPath.row]
            let timeText = result.time?.time ?? result.status
            cell.configure(
                title: "P\(result.position)  \(result.driver.fullName)",
                subtitle: result.constructor.name,
                value: timeText,
                systemImage: indexPath.row < 3 ? "trophy.fill" : "flag.checkered"
            )

        case "Qualifying":
            let result = qualifyingResults[indexPath.row]
            let best = result.q3 ?? result.q2 ?? result.q1 ?? "—"
            cell.configure(
                title: "P\(result.position)  \(result.driver.fullName)",
                subtitle: result.constructor.name,
                value: best,
                systemImage: "timer"
            )

        case "Weekend schedule":
            let session = race.sessions[indexPath.row]
            cell.configure(
                title: session.0,
                subtitle: session.1,
                value: session.2.uppercased(),
                systemImage: session.2 == "completed" ? "checkmark.circle" : "clock"
            )

        case "Track facts":
            let fact = trackFacts()[indexPath.row]
            cell.configure(title: fact.0, subtitle: circuit.name, value: fact.1, systemImage: "speedometer")

        default:
            break
        }

        return cell
    }

    private func trackFacts() -> [(String, String)] {
        var facts: [(String, String)] = []
        if circuit.length != "TBA" { facts.append(("Length", circuit.length)) }
        if circuit.turns > 0 { facts.append(("Turns", "\(circuit.turns)")) }
        if circuit.laps > 0 { facts.append(("Race laps", "\(circuit.laps)")) }
        if circuit.distance != "TBA" { facts.append(("Distance", circuit.distance)) }
        if circuit.lapRecord != "TBA" { facts.append(("Lap record", circuit.lapRecord)) }
        if circuit.drs != "TBA" { facts.append(("DRS", circuit.drs)) }
        if facts.isEmpty { facts.append(("Calendar source", "\(SeasonConfig.currentSeason) season")) }
        return facts
    }

    private func circuitHeroCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let hero = HeroImageView(imageName: circuit.photoName)
        cell.contentView.addSubview(hero)
        hero.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        let title = UILabel()
        title.text = circuit.name
        title.textColor = .white
        title.font = F1Fonts.title(28)
        title.numberOfLines = 2

        let subtitle = UILabel()
        subtitle.text = "\(circuit.city), \(circuit.country)"
        subtitle.textColor = F1Colors.textSecondary
        subtitle.font = F1Fonts.body(15)

        let badge = BadgeLabel(text: race.status, color: F1Colors.primaryRed)
        let map = UIImageView(image: UIImage(named: circuit.trackImageName) ?? UIImage(systemName: "map.fill"))
        map.contentMode = .scaleAspectFit
        map.tintColor = .white

        let stack = UIStackView(axis: .vertical, spacing: 8)
        [badge, title, subtitle].forEach(stack.addArrangedSubview)
        hero.addSubview(stack)
        hero.addSubview(map)
        stack.translatesAutoresizingMaskIntoConstraints = false
        map.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -24),
            map.topAnchor.constraint(equalTo: hero.topAnchor, constant: 20),
            map.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            map.widthAnchor.constraint(equalToConstant: 150),
            map.heightAnchor.constraint(equalToConstant: 110)
        ])

        return cell
    }
}
