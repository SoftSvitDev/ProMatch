import UIKit

final class CardView: UIView {
    init(background: UIColor = Theme.Color.surface, radius: CGFloat = Theme.Metric.cardRadius) {
        super.init(frame: .zero)
        backgroundColor = background
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class StatusBarSpacer: UIView {}

final class NavBarView: UIView {
    let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        b.tintColor = Theme.Color.textPrimary
        b.backgroundColor = Theme.Color.surface
        b.layer.cornerRadius = 18
        return b
    }()
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(20)
        l.textColor = Theme.Color.textPrimary
        return l
    }()
    let trailingButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = Theme.Color.textPrimary
        b.isHidden = true
        return b
    }()

    init(title: String, showsBack: Bool = true, trailingSymbol: String? = nil) {
        super.init(frame: .zero)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(trailingButton)
        titleLabel.text = title
        backButton.isHidden = !showsBack
        if let symbol = trailingSymbol {
            trailingButton.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)), for: .normal)
            trailingButton.isHidden = false
        }
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trailingButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingButton.widthAnchor.constraint(equalToConstant: 36),
            trailingButton.heightAnchor.constraint(equalToConstant: 36),

            heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class TeamBadge: UIView {
    let label = UILabel()
    let imageView = UIImageView()
    init(initials: String, color: UIColor, size: CGFloat = 44, fontSize: CGFloat = 18) {
        super.init(frame: .zero)
        backgroundColor = color
        layer.cornerRadius = 10
        clipsToBounds = true
        label.text = initials
        label.textColor = .white
        label.font = Theme.Font.bold(fontSize)
        label.textAlignment = .center
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        addSubview(imageView)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),

            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class PillLabel: UILabel {
    init(text: String, textColor: UIColor, background: UIColor, fontSize: CGFloat = 11) {
        super.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.backgroundColor = background
        self.font = Theme.Font.bold(fontSize)
        self.textAlignment = .center
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + 12, height: s.height + 4)
    }
}
