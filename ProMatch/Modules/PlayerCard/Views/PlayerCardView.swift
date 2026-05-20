import UIKit
import SnapKit

final class PlayerCardView: UIView {
    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()
    let contentView = UIView()

    let headerGradient: GradientView = {
        let v = GradientView()
        v.colors = [UIColor(hex: 0xE53E3E), UIColor(hex: 0x6B1717)]
        return v
    }()

    let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        b.layer.cornerRadius = 16
        return b
    }()

    let logoView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: 0xEF4444)
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.tag = 99
        v.addSubview(iv)
        iv.snp.makeConstraints { $0.edges.equalToSuperview() }
        let l = UILabel()
        l.text = ""
        l.textColor = .white
        l.font = Theme.Font.bold(20)
        v.addSubview(l)
        l.snp.makeConstraints { $0.center.equalToSuperview() }
        return v
    }()

    let nameLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(22)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(13)
        l.textColor = .white.withAlphaComponent(0.7)
        l.textAlignment = .center
        return l
    }()

    let winsBox = StatBox(color: Theme.Color.win, title: "Wins")
    let drawsBox = StatBox(color: Theme.Color.draw, title: "Draws")
    let lossesBox = StatBox(color: Theme.Color.loss, title: "Losses")

    let tabsView = SegmentedTabsView(items: ["Squad", "Matches", "Stats"])

    let playerCountLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(13)
        l.textColor = Theme.Color.textSecondary
        return l
    }()

    let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("  Add", for: .normal)
        b.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        b.setTitleColor(Theme.Color.onAccent, for: .normal)
        b.tintColor = Theme.Color.onAccent
        b.titleLabel?.font = Theme.Font.bold(13)
        b.backgroundColor = Theme.Color.accent
        b.layer.cornerRadius = 14
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return b
    }()

    let playersStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        [headerGradient, backButton, logoView, nameLabel, subtitleLabel,
         winsBox, drawsBox, lossesBox, tabsView,
         playerCountLabel, addButton, playersStack].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        headerGradient.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(190)
        }
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(32)
        }
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }

        winsBox.snp.makeConstraints { make in
            make.top.equalTo(headerGradient.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(drawsBox)
            make.height.equalTo(70)
        }
        drawsBox.snp.makeConstraints { make in
            make.top.equalTo(winsBox)
            make.leading.equalTo(winsBox.snp.trailing).offset(8)
            make.width.equalTo(lossesBox)
            make.height.equalTo(70)
        }
        lossesBox.snp.makeConstraints { make in
            make.top.equalTo(winsBox)
            make.leading.equalTo(drawsBox.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(70)
        }

        tabsView.snp.makeConstraints { make in
            make.top.equalTo(winsBox.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }

        playerCountLabel.snp.makeConstraints { make in
            make.top.equalTo(tabsView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(playerCountLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(28)
        }
        playersStack.snp.makeConstraints { make in
            make.top.equalTo(playerCountLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
}

final class StatBox: UIView {
    let valueLabel: UILabel
    let titleLabel: UILabel

    init(color: UIColor, title: String) {
        valueLabel = UILabel()
        titleLabel = UILabel()
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        valueLabel.font = Theme.Font.bold(24)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.font = Theme.Font.regular(12)
        titleLabel.textColor = Theme.Color.textSecondary
        titleLabel.textAlignment = .center
        addSubview(valueLabel)
        addSubview(titleLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class SegmentedTabsView: UIView {
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        return s
    }()
    var onChange: ((Int) -> Void)?
    private(set) var selectedIndex = 0
    private var buttons: [UIButton] = []

    init(items: [String]) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = 10
        clipsToBounds = true
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        for (i, item) in items.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(item, for: .normal)
            b.titleLabel?.font = Theme.Font.semibold(13)
            b.tag = i
            b.layer.cornerRadius = 8
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
            buttons.append(b)
        }
        select(0)
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func tap(_ sender: UIButton) {
        select(sender.tag)
        onChange?(sender.tag)
    }

    func select(_ index: Int) {
        selectedIndex = index
        for (i, b) in buttons.enumerated() {
            if i == index {
                b.backgroundColor = Theme.Color.accent
                b.setTitleColor(Theme.Color.onAccent, for: .normal)
            } else {
                b.backgroundColor = .clear
                b.setTitleColor(Theme.Color.textSecondary, for: .normal)
            }
        }
    }
}

final class GradientView: UIView {
    var colors: [UIColor] = [] {
        didSet { applyGradient() }
    }
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    private func applyGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

final class PlayerRowView: UIControl {
    let jerseyLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(15)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        return l
    }()

    let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.surfaceElevated
        v.layer.cornerRadius = 16
        return v
    }()

    let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(12)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    let nameLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.semibold(15)
        l.textColor = .white
        return l
    }()

    let positionPill: PillLabel

    let dragIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "line.3.horizontal"))
        iv.tintColor = Theme.Color.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(player: Player) {
        positionPill = PillLabel(text: player.position.rawValue,
                                 textColor: .black,
                                 background: player.position.pillColor,
                                 fontSize: 10)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = 12

        jerseyLabel.text = "\(player.jerseyNumber)"
        initialsLabel.text = player.initials
        nameLabel.text = player.fullName

        addSubview(jerseyLabel)
        addSubview(avatarView)
        avatarView.addSubview(initialsLabel)
        addSubview(nameLabel)
        addSubview(positionPill)
        addSubview(dragIcon)

        jerseyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalTo(jerseyLabel.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        positionPill.snp.makeConstraints { make in
            make.trailing.equalTo(dragIcon.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        dragIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        snp.makeConstraints { $0.height.equalTo(56) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class PlayerDetailView: UIView {
    let navBar = NavBarView(title: "Player")

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()
    private let contentView = UIView()

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 40
        return v
    }()
    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(32)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(22)
        l.textColor = Theme.Color.textPrimary
        l.textAlignment = .center
        return l
    }()
    private let nicknameLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(14)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        return l
    }()
    private let teamLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.semibold(13)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        return l
    }()
    private var positionPill: PillLabel?

    private let infoCard = CardView()
    private let infoStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 0
        return s
    }()

    let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Delete Player", for: .normal)
        b.setTitleColor(Theme.Color.loss, for: .normal)
        b.titleLabel?.font = Theme.Font.semibold(15)
        b.backgroundColor = Theme.Color.surface
        b.layer.cornerRadius = Theme.Metric.cardRadius
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(navBar)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        avatarView.addSubview(initialsLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(teamLabel)
        contentView.addSubview(infoCard)
        infoCard.addSubview(infoStack)
        contentView.addSubview(deleteButton)

        navBar.snp.makeConstraints { make in
            make.top.equalTo(safeTop)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        teamLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        infoCard.snp.makeConstraints { make in
            make.top.equalTo(teamLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        infoStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)) }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(infoCard.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(Theme.Metric.buttonHeight)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    func configure(player: Player, team: Team) {
        avatarView.backgroundColor = team.color
        initialsLabel.text = player.initials
        nameLabel.text = player.fullName
        if let nick = player.nickname, !nick.isEmpty {
            nicknameLabel.text = "\u{201C}\(nick)\u{201D}"
            nicknameLabel.isHidden = false
        } else {
            nicknameLabel.isHidden = true
        }
        teamLabel.text = team.name

        positionPill?.removeFromSuperview()
        let pill = PillLabel(text: player.position.rawValue,
                             textColor: .black,
                             background: player.position.pillColor,
                             fontSize: 12)
        contentView.addSubview(pill)
        pill.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.top).offset(-4)
            make.leading.equalTo(avatarView.snp.trailing).offset(-8)
            make.height.equalTo(22)
        }
        positionPill = pill

        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addInfoRow("Position", player.position.rawValue)
        addInfoRow("Jersey", "#\(player.jerseyNumber)")
        addInfoRow("Preferred foot", player.preferredFoot.rawValue)
        if let h = player.heightCm { addInfoRow("Height", "\(h) cm") }
        if let w = player.weightKg { addInfoRow("Weight", "\(w) kg") }
        if let d = player.birthDate {
            let f = DateFormatter(); f.dateStyle = .medium
            addInfoRow("Birth date", f.string(from: d))
        }
    }

    private func addInfoRow(_ key: String, _ value: String) {
        if !infoStack.arrangedSubviews.isEmpty {
            let line = UIView()
            line.backgroundColor = Theme.Color.divider
            line.snp.makeConstraints { $0.height.equalTo(0.5) }
            infoStack.addArrangedSubview(line)
        }
        let row = UIView()
        let k = UILabel()
        k.text = key; k.font = Theme.Font.regular(14); k.textColor = Theme.Color.textSecondary
        let v = UILabel()
        v.text = value; v.font = Theme.Font.semibold(14); v.textColor = Theme.Color.textPrimary
        v.textAlignment = .right
        row.addSubview(k); row.addSubview(v)
        k.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        v.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(k.snp.trailing).offset(8)
        }
        row.snp.makeConstraints { $0.height.equalTo(44) }
        infoStack.addArrangedSubview(row)
    }
}
