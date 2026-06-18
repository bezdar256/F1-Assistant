import UIKit

final class InfoCardCell: UITableViewCell {
    static let reuseId = "InfoCardCell"
    private let card = F1CardView(); private let titleLabel = UILabel(); private let subtitleLabel = UILabel(); private let valueLabel = UILabel(); private let icon = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear; selectionStyle = .none
        contentView.addSubview(card); card.pinToSuperview(insets: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        icon.tintColor = F1Colors.primaryRed; icon.contentMode = .scaleAspectFit
        titleLabel.textColor = .white; titleLabel.font = F1Fonts.subtitle(17)
        subtitleLabel.textColor = F1Colors.textSecondary; subtitleLabel.font = F1Fonts.body(13); subtitleLabel.numberOfLines = 2
        valueLabel.textColor = F1Colors.primaryRed; valueLabel.font = F1Fonts.mono(13); valueLabel.textAlignment = .right
        let textStack = UIStackView(axis: .vertical, spacing: 4); textStack.addArrangedSubview(titleLabel); textStack.addArrangedSubview(subtitleLabel)
        let row = UIStackView(axis: .horizontal, spacing: 12, alignment: .center); row.addArrangedSubview(icon); row.addArrangedSubview(textStack); row.addArrangedSubview(valueLabel)
        card.addSubview(row); NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: card.topAnchor, constant: 14), row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14), row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14), row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14), icon.widthAnchor.constraint(equalToConstant: 34), icon.heightAnchor.constraint(equalToConstant: 34), valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 72)])
    }
    func configure(title: String, subtitle: String, value: String? = nil, systemImage: String = "flag.checkered") { titleLabel.text = title; subtitleLabel.text = subtitle; valueLabel.text = value; icon.image = UIImage(systemName: systemImage) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class DriverCardCell: UITableViewCell {
    static let reuseId = "DriverCardCell"
    private let card = F1CardView(); private let photo = UIImageView(); private let name = UILabel(); private let meta = UILabel(); private let stats = UILabel(); private let line = LineChartView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none
        contentView.addSubview(card); card.pinToSuperview(insets: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        photo.contentMode = .scaleAspectFill; photo.rounded(18); photo.backgroundColor = F1Colors.cardSecondary
        name.textColor = .white; name.font = F1Fonts.subtitle(19)
        meta.textColor = F1Colors.textSecondary; meta.font = F1Fonts.caption(12)
        stats.textColor = .white; stats.font = F1Fonts.mono(12); stats.numberOfLines = 2
        line.backgroundColor = .clear
        let v = UIStackView(axis: .vertical, spacing: 5); [name, meta, stats, line].forEach(v.addArrangedSubview)
        let row = UIStackView(axis: .horizontal, spacing: 14, alignment: .center); row.addArrangedSubview(photo); row.addArrangedSubview(v)
        card.addSubview(row); NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: card.topAnchor, constant: 12), row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12), row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12), row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12), photo.widthAnchor.constraint(equalToConstant: 92), photo.heightAnchor.constraint(equalToConstant: 92), line.heightAnchor.constraint(equalToConstant: 32)])
    }
    func configure(_ d: LocalDriver) {
        photo.image = UIImage(named: d.imageName) ?? UIImage(systemName: "person.crop.square.fill")
        name.text = "#\(d.number)  \(d.name)"
        if d.position > 0 {
            meta.text = "P\(d.position) • \(d.team) • \(d.nationality)"
            stats.text = "\(Int(d.points)) pts  •  \(d.wins) wins"
        } else {
            meta.text = "\(d.team) • \(d.nationality)"
            stats.text = "Standings update unavailable"
        }
        line.isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class TeamCardCell: UITableViewCell {
    static let reuseId = "TeamCardCell"
    private let card = F1CardView()
    private let car = UIImageView()
    private let logo = UIImageView()
    private let name = UILabel()
    private let details = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(card)
        card.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        car.contentMode = .scaleAspectFill
        car.rounded(18)
        car.backgroundColor = F1Colors.cardSecondary

        logo.contentMode = .scaleAspectFit
        name.textColor = .white
        name.font = F1Fonts.title(23)
        details.textColor = F1Colors.textSecondary
        details.font = F1Fonts.body(13)
        details.numberOfLines = 3

        card.addSubview(car)
        card.addSubview(logo)
        card.addSubview(name)
        card.addSubview(details)
        [car, logo, name, details].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            car.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            car.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            car.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            car.heightAnchor.constraint(equalToConstant: 120),

            logo.topAnchor.constraint(equalTo: car.bottomAnchor, constant: 12),
            logo.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            logo.widthAnchor.constraint(equalToConstant: 48),
            logo.heightAnchor.constraint(equalToConstant: 48),

            name.topAnchor.constraint(equalTo: car.bottomAnchor, constant: 12),
            name.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 12),
            name.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            details.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 3),
            details.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            details.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            details.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func configure(_ team: LocalTeam) {
        car.image = UIImage(named: team.carImageName) ?? UIImage(systemName: "car.fill")
        logo.image = UIImage(named: team.logoName) ?? UIImage(systemName: "shield.fill")
        name.text = team.name
        let drivers = team.drivers.isEmpty ? "Drivers update with standings" : team.drivers.joined(separator: " / ")
        if team.position > 0 {
            details.text = "P\(team.position) • \(Int(team.points)) pts\n\(drivers)"
        } else {
            details.text = "Standings update unavailable\n\(drivers)"
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class LiveTimingCell: UITableViewCell {
    static let reuseId = "LiveTimingCell"
    private let pos = UILabel(); private let code = UILabel(); private let team = UILabel(); private let gap = UILabel(); private let tyre = BadgeLabel(); private let pits = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); backgroundColor = .clear; selectionStyle = .none
        [pos,code,team,gap,pits].forEach { $0.font = F1Fonts.mono(13); $0.textColor = .white }
        team.textColor = F1Colors.textSecondary; gap.textAlignment = .right; pits.textAlignment = .right
        let row = UIStackView(axis: .horizontal, spacing: 8, alignment: .center)
        [pos,code,team,gap,tyre,pits].forEach(row.addArrangedSubview)
        contentView.addSubview(row); NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18), row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18), row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8), pos.widthAnchor.constraint(equalToConstant: 32), code.widthAnchor.constraint(equalToConstant: 46), gap.widthAnchor.constraint(equalToConstant: 72), tyre.widthAnchor.constraint(equalToConstant: 62), pits.widthAnchor.constraint(equalToConstant: 30)])
    }
    func configure(_ r: LiveRow) { pos.text = "P\(r.position)"; code.text = r.code; team.text = r.team; gap.text = r.gap; tyre.text = "  \(r.tyre.uppercased().prefix(3))  "; tyre.backgroundColor = F1Colors.tyre(r.tyre); tyre.textColor = r.tyre.lowercased() == "hard" ? .black : .white; pits.text = "\(r.pitStops)" }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
