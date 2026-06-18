import UIKit

final class DriverDetailViewController: BaseTableViewController, UITableViewDataSource {
    private let driver: LocalDriver

    init(driver: LocalDriver) {
        self.driver = driver
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = driver.code
        tableView.dataSource = self
        tableView.register(InfoCardCell.self, forCellReuseIdentifier: InfoCardCell.reuseId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(fav))
    }

    @objc private func fav() {
        FavoritesStorage.shared.favoriteDriverId = driver.id
        navigationController?.popViewController(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Profile", "\(SeasonConfig.currentSeason) season stats"][section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 1 ? 3 : 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 310 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { return hero() }
        let facts: [(String, String)]
        if driver.position > 0 {
            facts = [
                ("Championship position", "P\(driver.position)"),
                ("Points", "\(Int(driver.points))"),
                ("Race wins", "\(driver.wins)")
            ]
        } else {
            facts = [
                ("Standings", "Updating"),
                ("Points", "Unavailable"),
                ("Race wins", "Unavailable")
            ]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCardCell.reuseId, for: indexPath) as! InfoCardCell
        let fact = facts[indexPath.row]
        cell.configure(title: fact.0, subtitle: driver.team, value: fact.1, systemImage: "chart.bar.fill")
        return cell
    }

    private func hero() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let image = HeroImageView(imageName: driver.imageName)
        cell.contentView.addSubview(image)
        image.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        let title = UILabel()
        title.text = "#\(driver.number)  \(driver.name)"
        title.textColor = .white
        title.font = F1Fonts.title(28)
        title.numberOfLines = 2

        let subtitle = UILabel()
        subtitle.text = "\(driver.team) • \(driver.nationality)"
        subtitle.textColor = F1Colors.textSecondary
        subtitle.font = F1Fonts.body()

        let badgeText = driver.position > 0 ? "P\(driver.position) • \(Int(driver.points)) PTS" : "STANDINGS UPDATING"
        let badge = BadgeLabel(text: badgeText, color: TeamColors.color(for: driver.teamId))
        let stack = UIStackView(axis: .vertical, spacing: 8)
        [badge, title, subtitle].forEach { stack.addArrangedSubview($0) }
        image.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: image.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: image.bottomAnchor, constant: -22)
        ])
        return cell
    }


}
