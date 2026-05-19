import UIKit
import SnapKit

final class ProfileView: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = .white
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

        contentStack.addArrangedSubview(makeRow(symbol: "moon.fill", iconColor: Theme.Color.draw, title: "Appearance", value: "Dark Mode"))
        contentStack.addArrangedSubview(makeRow(symbol: "globe", iconColor: Theme.Color.pillBlue, title: "Language", value: "English"))
        contentStack.addArrangedSubview(makeRow(symbol: "gearshape", iconColor: Theme.Color.textSecondary, title: "Default Formation", value: "4-3-3"))
        contentStack.addArrangedSubview(makeRow(symbol: "bell.fill", iconColor: Theme.Color.draw, title: "Notifications", value: "On"))

        contentStack.setCustomSpacing(20, after: contentStack.arrangedSubviews.last!)
        let legalHeader = SectionHeaderLabel("Legal & Support")
        contentStack.addArrangedSubview(legalHeader)
        contentStack.setCustomSpacing(8, after: legalHeader)

        contentStack.addArrangedSubview(makeRow(symbol: "star.fill", iconColor: Theme.Color.draw, title: "Rate Us", value: "★★★★★"))
        contentStack.addArrangedSubview(makeRow(symbol: "lock.fill", iconColor: Theme.Color.textSecondary, title: "Privacy Policy", value: nil))
        contentStack.addArrangedSubview(makeRow(symbol: "doc.text.fill", iconColor: Theme.Color.textSecondary, title: "Terms of Use", value: nil))

        contentStack.setCustomSpacing(20, after: contentStack.arrangedSubviews.last!)
        contentStack.addArrangedSubview(makeAppFooter())
    }

    private func makeUserCard() -> UIView {
        let card = CardView()
        let badge = TeamBadge(initials: "C", color: Theme.Color.accent, size: 56, fontSize: 24)
        badge.label.textColor = .black
        let name = UILabel()
        name.text = "Coach"
        name.font = Theme.Font.bold(18)
        name.textColor = .white
        let role = UILabel()
        role.text = "Amateur Football Manager"
        role.font = Theme.Font.regular(13)
        role.textColor = Theme.Color.textSecondary
        let pro = PillLabel(text: "PRO", textColor: Theme.Color.accent, background: Theme.Color.accent.withAlphaComponent(0.18), fontSize: 10)

        [badge, name, role, pro].forEach { card.addSubview($0) }
        badge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(56)
        }
        name.snp.makeConstraints { make in
            make.leading.equalTo(badge.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(18)
        }
        role.snp.makeConstraints { make in
            make.leading.equalTo(name)
            make.top.equalTo(name.snp.bottom).offset(2)
        }
        pro.snp.makeConstraints { make in
            make.leading.equalTo(name)
            make.top.equalTo(role.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        card.snp.makeConstraints { $0.height.equalTo(96) }
        return card
    }

    private func makeStatsRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually

        func makeStat(symbol: String, color: UIColor, value: String, title: String) -> UIView {
            let v = CardView()
            let icon = UIImageView(image: UIImage(systemName: symbol))
            icon.tintColor = color
            icon.contentMode = .scaleAspectFit
            let val = UILabel()
            val.text = value
            val.font = Theme.Font.bold(20)
            val.textColor = .white
            val.textAlignment = .center
            let t = UILabel()
            t.text = title
            t.font = Theme.Font.regular(11)
            t.textColor = Theme.Color.textSecondary
            t.textAlignment = .center
            v.addSubview(icon)
            v.addSubview(val)
            v.addSubview(t)
            icon.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.centerX.equalToSuperview()
                make.size.equalTo(18)
            }
            val.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(4)
                make.centerX.equalToSuperview()
            }
            t.snp.makeConstraints { make in
                make.top.equalTo(val.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
            }
            v.snp.makeConstraints { $0.height.equalTo(90) }
            return v
        }

        row.addArrangedSubview(makeStat(symbol: "shield.fill", color: Theme.Color.pillRed, value: "3", title: "Teams"))
        row.addArrangedSubview(makeStat(symbol: "person.fill", color: Theme.Color.pillBlue, value: "9", title: "Players"))
        row.addArrangedSubview(makeStat(symbol: "trophy.fill", color: Theme.Color.draw, value: "3", title: "Tournaments"))
        return row
    }

    private func makeRow(symbol: String, iconColor: UIColor, title: String, value: String?) -> UIView {
        let v = CardView()
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = iconColor
        icon.contentMode = .scaleAspectFit
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.semibold(15)
        titleLabel.textColor = .white
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = Theme.Color.textTertiary
        chevron.contentMode = .scaleAspectFit
        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = Theme.Font.regular(13)
        valLabel.textColor = Theme.Color.textSecondary

        [icon, titleLabel, valLabel, chevron].forEach { v.addSubview($0) }
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
        valLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevron.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        v.snp.makeConstraints { $0.height.equalTo(54) }
        return v
    }

    private func makeAppFooter() -> UIView {
        let v = CardView()
        let title = UILabel()
        title.text = "Squad Manager: Football"
        title.font = Theme.Font.bold(14)
        title.textColor = .white
        let version = UILabel()
        version.text = "Version 1.0.0"
        version.font = Theme.Font.regular(11)
        version.textColor = Theme.Color.textSecondary

        let logo = UIView()
        logo.backgroundColor = Theme.Color.accent
        logo.layer.cornerRadius = 16
        let logoIcon = UIImageView(image: UIImage(systemName: "soccerball"))
        logoIcon.tintColor = .black
        logoIcon.contentMode = .scaleAspectFit
        logo.addSubview(logoIcon)
        logoIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }

        v.addSubview(title)
        v.addSubview(version)
        v.addSubview(logo)
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
