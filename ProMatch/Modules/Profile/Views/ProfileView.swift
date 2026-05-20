import UIKit
import SnapKit

final class ProfileView: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = Theme.Color.textPrimary
        l.text = "Profile"
        return l
    }()

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        s.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return s
    }()
    let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        return s
    }()

    // Exposed controls
    let userNameLabel = UILabel()
    let editNameButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit", for: .normal)
        b.setTitleColor(Theme.Color.accent, for: .normal)
        b.titleLabel?.font = Theme.Font.semibold(13)
        return b
    }()
    let appearanceRow = SettingsRowView(symbol: "moon.fill", iconColor: Theme.Color.draw, title: "Appearance")
    let notificationsRow = SettingsRowView(symbol: "bell.fill", iconColor: Theme.Color.draw, title: "Notifications")
    let notificationsSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = Theme.Color.accent
        return s
    }()
    let defaultFormationRow = SettingsRowView(symbol: "gearshape", iconColor: Theme.Color.textSecondary, title: "Default Formation", value: "4-3-3")
    let rateUsRow = SettingsRowView(symbol: "star.fill", iconColor: Theme.Color.draw, title: "Rate Us", value: "★★★★★")
    let privacyRow = SettingsRowView(symbol: "lock.fill", iconColor: Theme.Color.textSecondary, title: "Privacy Policy")
    let termsRow = SettingsRowView(symbol: "doc.text.fill", iconColor: Theme.Color.textSecondary, title: "Terms of Use")

    private let teamsValueLabel = UILabel()
    private let playersValueLabel = UILabel()
    private let tournamentsValueLabel = UILabel()

    func applyCounts(teams: Int, players: Int, tournaments: Int) {
        teamsValueLabel.text = "\(teams)"
        playersValueLabel.text = "\(players)"
        tournamentsValueLabel.text = "\(tournaments)"
    }

    func applyUserName(_ name: String) {
        userNameLabel.text = name
    }

    func applyAppearance(_ display: String) {
        appearanceRow.valueLabel.text = display
    }

    func applyNotifications(enabled: Bool) {
        notificationsSwitch.isOn = enabled
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeTop).offset(8)
            make.leading.equalToSuperview().offset(24)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.width.equalTo(scrollView).offset(-48)
        }
    }

    private func build() {
        let card = makeUserCard()
        contentStack.addArrangedSubview(card)

        let stats = makeStatsRow()
        contentStack.addArrangedSubview(stats)

        contentStack.setCustomSpacing(20, after: stats)

        let prefsHeader = SectionHeaderLabel("Preferences")
        contentStack.addArrangedSubview(prefsHeader)
        contentStack.setCustomSpacing(8, after: prefsHeader)

        contentStack.addArrangedSubview(appearanceRow)
        contentStack.addArrangedSubview(defaultFormationRow)
        contentStack.addArrangedSubview(configureNotificationsRow())

        contentStack.setCustomSpacing(20, after: contentStack.arrangedSubviews.last!)
        let legalHeader = SectionHeaderLabel("Legal & Support")
        contentStack.addArrangedSubview(legalHeader)
        contentStack.setCustomSpacing(8, after: legalHeader)

        contentStack.addArrangedSubview(rateUsRow)
        contentStack.addArrangedSubview(privacyRow)
        contentStack.addArrangedSubview(termsRow)

        contentStack.setCustomSpacing(20, after: contentStack.arrangedSubviews.last!)
        contentStack.addArrangedSubview(makeAppFooter())
    }

    private func configureNotificationsRow() -> UIView {
        // Replace the chevron + value in the right slot with a UISwitch.
        notificationsRow.chevronImageView.isHidden = true
        notificationsRow.valueLabel.isHidden = true
        notificationsRow.addSubview(notificationsSwitch)
        notificationsSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        notificationsRow.isUserInteractionEnabled = true
        return notificationsRow
    }

    private func makeUserCard() -> UIView {
        let card = CardView()
        let badge = TeamBadge(initials: "C", color: Theme.Color.accent, size: 56, fontSize: 24)
        badge.label.textColor = Theme.Color.onAccent

        userNameLabel.font = Theme.Font.bold(18)
        userNameLabel.textColor = Theme.Color.textPrimary

        let role = UILabel()
        role.text = "Amateur Football Manager"
        role.font = Theme.Font.regular(13)
        role.textColor = Theme.Color.textSecondary

        let pro = PillLabel(text: "PRO", textColor: Theme.Color.accent,
                            background: Theme.Color.accent.withAlphaComponent(0.18), fontSize: 10)

        [badge, userNameLabel, role, pro, editNameButton].forEach { card.addSubview($0) }
        badge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(56)
        }
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(badge.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(18)
        }
        role.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.top.equalTo(userNameLabel.snp.bottom).offset(2)
        }
        pro.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.top.equalTo(role.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        editNameButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        card.snp.makeConstraints { $0.height.equalTo(96) }
        return card
    }

    private func makeStatsRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually

        func makeStat(symbol: String, color: UIColor, valueLabel: UILabel, title: String) -> UIView {
            let v = CardView()
            let icon = UIImageView(image: UIImage(systemName: symbol))
            icon.tintColor = color
            icon.contentMode = .scaleAspectFit
            valueLabel.text = "0"
            valueLabel.font = Theme.Font.bold(20)
            valueLabel.textColor = Theme.Color.textPrimary
            valueLabel.textAlignment = .center
            let t = UILabel()
            t.text = title
            t.font = Theme.Font.regular(11)
            t.textColor = Theme.Color.textSecondary
            t.textAlignment = .center
            v.addSubview(icon)
            v.addSubview(valueLabel)
            v.addSubview(t)
            icon.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.centerX.equalToSuperview()
                make.size.equalTo(18)
            }
            valueLabel.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(4)
                make.centerX.equalToSuperview()
            }
            t.snp.makeConstraints { make in
                make.top.equalTo(valueLabel.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
            }
            v.snp.makeConstraints { $0.height.equalTo(90) }
            return v
        }

        row.addArrangedSubview(makeStat(symbol: "shield.fill", color: Theme.Color.pillRed, valueLabel: teamsValueLabel, title: "Teams"))
        row.addArrangedSubview(makeStat(symbol: "person.fill", color: Theme.Color.pillBlue, valueLabel: playersValueLabel, title: "Players"))
        row.addArrangedSubview(makeStat(symbol: "trophy.fill", color: Theme.Color.draw, valueLabel: tournamentsValueLabel, title: "Tournaments"))
        return row
    }

    private func makeAppFooter() -> UIView {
        let v = CardView()
        let title = UILabel()
        title.text = "ProMatch 24"
        title.font = Theme.Font.bold(14)
        title.textColor = Theme.Color.textPrimary
        let version = UILabel()
        version.text = "Version 1.0.0"
        version.font = Theme.Font.regular(11)
        version.textColor = Theme.Color.textSecondary

        let logo = UIView()
        logo.backgroundColor = Theme.Color.accent
        logo.layer.cornerRadius = 16
        let logoIcon = UIImageView(image: UIImage(systemName: "soccerball"))
        logoIcon.tintColor = Theme.Color.onAccent
        logoIcon.contentMode = .scaleAspectFit
        logo.addSubview(logoIcon)
        logoIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }

        v.addSubview(title); v.addSubview(version); v.addSubview(logo)
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
        }
        version.snp.makeConstraints { make in
            make.leading.equalTo(title)
            make.top.equalTo(title.snp.bottom).offset(2)
        }
        logo.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        v.snp.makeConstraints { $0.height.equalTo(60) }
        return v
    }
}

final class SettingsRowView: UIControl {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let chevronImageView = UIImageView()

    init(symbol: String, iconColor: UIColor, title: String, value: String? = nil) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        iconView.image = UIImage(systemName: symbol)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = Theme.Font.semibold(15)
        titleLabel.textColor = Theme.Color.textPrimary

        valueLabel.text = value
        valueLabel.font = Theme.Font.regular(13)
        valueLabel.textColor = Theme.Color.textSecondary

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = Theme.Color.textTertiary
        chevronImageView.contentMode = .scaleAspectFit

        [iconView, titleLabel, valueLabel, chevronImageView].forEach { addSubview($0) }
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(54) }
    }
    required init?(coder: NSCoder) { fatalError() }
}
