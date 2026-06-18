import UIKit

extension UIView {
    func pinToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
    func rounded(_ radius: CGFloat = 20) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    func applyCardStyle(radius: CGFloat = 20) {
        backgroundColor = F1Colors.card
        rounded(radius)
        layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        layer.borderWidth = 1
    }
}

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) {
        self.init(frame: .zero)
        self.axis = axis; self.spacing = spacing; self.alignment = alignment; self.distribution = distribution
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class F1CardView: UIView {
    init(radius: CGFloat = 20) { super.init(frame: .zero); applyCardStyle(radius: radius) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class BadgeLabel: UILabel {
    init(text: String = "", color: UIColor = F1Colors.primaryRed) {
        super.init(frame: .zero)
        self.text = "  \(text.uppercased())  "
        textColor = .white
        font = F1Fonts.caption(11)
        backgroundColor = color
        textAlignment = .center
        layer.cornerRadius = 9
        layer.masksToBounds = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 22).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class HeroImageView: UIImageView {
    init(imageName: String, title: String? = nil) {
        super.init(frame: .zero)
        image = UIImage(named: imageName) ?? UIImage(named: "f1_hero") ?? UIImage(systemName: "flag.checkered")
        contentMode = .scaleAspectFill
        clipsToBounds = true
        rounded(24)
        backgroundColor = F1Colors.cardSecondary
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.05).cgColor, UIColor.black.withAlphaComponent(0.82).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradient)
        DispatchQueue.main.async { gradient.frame = self.bounds }
    }
    override func layoutSubviews() { super.layoutSubviews(); layer.sublayers?.first?.frame = bounds }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class StatCardView: F1CardView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    init(title: String, value: String, accent: UIColor = F1Colors.primaryRed) {
        super.init(radius: 18)
        let accentView = UIView(); accentView.backgroundColor = accent; accentView.rounded(3)
        valueLabel.text = value; valueLabel.textColor = .white; valueLabel.font = F1Fonts.title(24)
        titleLabel.text = title; titleLabel.textColor = F1Colors.textSecondary; titleLabel.font = F1Fonts.caption(12)
        let stack = UIStackView(axis: .vertical, spacing: 4)
        stack.addArrangedSubview(valueLabel); stack.addArrangedSubview(titleLabel)
        addSubview(accentView); addSubview(stack)
        accentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            accentView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            accentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            accentView.widthAnchor.constraint(equalToConstant: 5),
            stack.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    func update(title: String, value: String) { titleLabel.text = title; valueLabel.text = value }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class LoadingView: UIView {
    init(text: String = "Loading F1 data…") {
        super.init(frame: .zero); backgroundColor = F1Colors.background
        let indicator = UIActivityIndicatorView(style: .large); indicator.color = F1Colors.primaryRed; indicator.startAnimating()
        let label = UILabel(); label.text = text; label.textColor = F1Colors.textSecondary; label.font = F1Fonts.body(); label.textAlignment = .center
        let stack = UIStackView(axis: .vertical, spacing: 12, alignment: .center)
        stack.addArrangedSubview(indicator); stack.addArrangedSubview(label); addSubview(stack)
        NSLayoutConstraint.activate([stack.centerXAnchor.constraint(equalTo: centerXAnchor), stack.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class EmptyStateView: UIView {
    init(title: String, message: String, systemImage: String = "flag.checkered") {
        super.init(frame: .zero); backgroundColor = F1Colors.background
        let icon = UIImageView(image: UIImage(systemName: systemImage)); icon.tintColor = F1Colors.primaryRed; icon.contentMode = .scaleAspectFit
        let titleLabel = UILabel(); titleLabel.text = title; titleLabel.textColor = .white; titleLabel.font = F1Fonts.subtitle(22); titleLabel.textAlignment = .center
        let msg = UILabel(); msg.text = message; msg.textColor = F1Colors.textSecondary; msg.font = F1Fonts.body(); msg.numberOfLines = 0; msg.textAlignment = .center
        let stack = UIStackView(axis: .vertical, spacing: 12, alignment: .center)
        [icon,titleLabel,msg].forEach(stack.addArrangedSubview); addSubview(stack)
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 42), icon.widthAnchor.constraint(equalToConstant: 42),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28), stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class BarChartView: UIView {
    var values: [(String, Double, UIColor)] = [] { didSet { setNeedsDisplay() } }
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !values.isEmpty else { return }
        let maxValue = max(values.map { $0.1 }.max() ?? 1, 1)
        let barH = min(28, (rect.height - CGFloat(values.count - 1) * 10) / CGFloat(values.count))
        for (i, item) in values.enumerated() {
            let y = CGFloat(i) * (barH + 10)
            let label = item.0 as NSString
            label.draw(in: CGRect(x: 0, y: y + 5, width: 82, height: barH), withAttributes: [.foregroundColor: F1Colors.textSecondary, .font: F1Fonts.caption(11)])
            let x: CGFloat = 90
            let w = (rect.width - x - 44) * CGFloat(item.1 / maxValue)
            let bg = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: rect.width - x - 44, height: barH), cornerRadius: 8)
            F1Colors.cardSecondary.setFill(); bg.fill()
            let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: max(6,w), height: barH), cornerRadius: 8)
            item.2.setFill(); bar.fill()
            let val = String(format: "%.0f", item.1) as NSString
            val.draw(in: CGRect(x: rect.width - 40, y: y + 5, width: 40, height: barH), withAttributes: [.foregroundColor: UIColor.white, .font: F1Fonts.mono(11)])
        }
        ctx.setShouldAntialias(true)
    }
}

final class LineChartView: UIView {
    var values: [Double] = [] { didSet { setNeedsDisplay() } }
    var lineColor: UIColor = F1Colors.primaryRed
    override func draw(_ rect: CGRect) {
        guard values.count > 1 else { return }
        let maxV = values.max() ?? 1, minV = values.min() ?? 0
        let path = UIBezierPath(); path.lineWidth = 3; path.lineJoinStyle = .round
        for (i,v) in values.enumerated() {
            let x = CGFloat(i) / CGFloat(values.count - 1) * rect.width
            let norm = (v - minV) / max(maxV - minV, 1)
            let y = rect.height - CGFloat(norm) * rect.height
            i == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
        }
        lineColor.setStroke(); path.stroke()
    }
}

final class DonutChartView: UIView {
    var slices: [(Double, UIColor)] = [] { didSet { setNeedsDisplay() } }
    override func draw(_ rect: CGRect) {
        let total = slices.reduce(0) { $0 + $1.0 }; guard total > 0 else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 8
        var start = -CGFloat.pi / 2
        for s in slices {
            let end = start + CGFloat(s.0 / total) * 2 * .pi
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
            path.lineWidth = 18; s.1.setStroke(); path.stroke(); start = end
        }
    }
}
