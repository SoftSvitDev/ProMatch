import UIKit
import SnapKit

final class TournamentsView: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = Theme.Color.textPrimary
        l.text = "Tournaments"
        return l
    }()

    let historyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)), for: .normal)
        b.tintColor = Theme.Color.textPrimary
        b.backgroundColor = Theme.Color.surface
        b.layer.cornerRadius = 18
        return b
    }()

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        s.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return s
    }()
    let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        return s
    }()

    let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = Theme.Color.accent
        b.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        b.tintColor = .black
        b.layer.cornerRadius = 28
        return b
    }()

    let emptyState: UIView = {
        let v = UIView()
        v.isHidden = true
        let icon = UIImageView(image: UIImage(systemName: "trophy"))
        icon.tintColor = Theme.Color.textTertiary
        icon.contentMode = .scaleAspectFit
        let title = UILabel()
        title.text = "No tournaments yet"
        title.font = Theme.Font.bold(17)
        title.textColor = Theme.Color.textPrimary
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Tap + to set up your first tournament"
        subtitle.font = Theme.Font.regular(13)
        subtitle.textColor = Theme.Color.textSecondary
        subtitle.textAlignment = .center
        v.addSubview(icon); v.addSubview(title); v.addSubview(subtitle)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(40)
        }
        title.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        [titleLabel, historyButton, scrollView, emptyState, addButton].forEach { addSubview($0) }
        scrollView.addSubview(contentStack)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeTop).offset(8)
            make.leading.equalToSuperview().offset(24)
        }
        historyButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(36)
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
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeBottom).offset(-24)
            make.size.equalTo(56)
        }
        emptyState.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
    }
}

final class SectionLabelView: UILabel {
    init(_ text: String, color: UIColor = Theme.Color.accent) {
        super.init(frame: .zero)
        self.attributedText = NSAttributedString(
            string: text.uppercased(),
            attributes: [.foregroundColor: color, .kern: 0.8,
                         .font: Theme.Font.bold(11)]
        )
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class TournamentRowView: UIControl {
    var tournamentId: UUID?
    let nameLabel = UILabel()
    let formatLabel = UILabel()
    let formatIcon = UIImageView()
    let teamCountIcon = UIImageView(image: UIImage(systemName: "person.2"))
    let teamCountLabel = UILabel()
    let dateIcon = UIImageView(image: UIImage(systemName: "calendar"))
    let dateLabel = UILabel()
    let statusPill: PillLabel
    let progressBar = UIView()
    let progressFill = UIView()

    init(tournament: Tournament) {
        let pillText: String
        let pillBg: UIColor
        let pillFg: UIColor
        switch tournament.status {
        case .live:
            pillText = "● Live"
            pillBg = Theme.Color.accent
            pillFg = .black
        case .scheduled:
            pillText = "Scheduled"
            pillBg = UIColor(hex: 0xFFBE5C).withAlphaComponent(0.15)
            pillFg = UIColor(hex: 0xFFBE5C)
        case .completed:
            pillText = "Finished"
            pillBg = Theme.Color.surfaceElevated
            pillFg = Theme.Color.textSecondary
        }
        statusPill = PillLabel(text: pillText, textColor: pillFg, background: pillBg, fontSize: 11)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        nameLabel.text = tournament.name
        nameLabel.font = Theme.Font.bold(17)
        nameLabel.textColor = Theme.Color.textPrimary

        formatLabel.text = tournament.format.rawValue
        formatLabel.font = Theme.Font.regular(13)
        formatLabel.textColor = Theme.Color.textSecondary

        let formatSymbol: String
        switch tournament.format {
        case .roundRobin: formatSymbol = "globe"
        case .knockout: formatSymbol = "flag"
        case .groupsPlayoffs: formatSymbol = "rectangle.grid.2x2"
        }
        formatIcon.image = UIImage(systemName: formatSymbol)
        formatIcon.tintColor = Theme.Color.textSecondary
        formatIcon.contentMode = .scaleAspectFit

        teamCountLabel.text = "\(tournament.teamIds.count) teams"
        teamCountLabel.font = Theme.Font.regular(12)
        teamCountLabel.textColor = Theme.Color.textSecondary
        teamCountIcon.tintColor = Theme.Color.textSecondary
        teamCountIcon.contentMode = .scaleAspectFit

        dateLabel.text = tournament.dateText
        dateLabel.font = Theme.Font.regular(12)
        dateLabel.textColor = Theme.Color.textSecondary
        dateIcon.tintColor = Theme.Color.textSecondary
        dateIcon.contentMode = .scaleAspectFit

        addSubview(nameLabel)
        addSubview(statusPill)
        addSubview(formatIcon)
        addSubview(formatLabel)
        addSubview(teamCountIcon)
        addSubview(teamCountLabel)
        addSubview(dateIcon)
        addSubview(dateLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.trailing.lessThanOrEqualTo(statusPill.snp.leading).offset(-8)
        }
        statusPill.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(22)
        }
        formatIcon.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.size.equalTo(14)
        }
        formatLabel.snp.makeConstraints { make in
            make.centerY.equalTo(formatIcon)
            make.leading.equalTo(formatIcon.snp.trailing).offset(6)
        }
        teamCountIcon.snp.makeConstraints { make in
            make.top.equalTo(formatIcon.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.size.equalTo(14)
        }
        teamCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(teamCountIcon)
            make.leading.equalTo(teamCountIcon.snp.trailing).offset(6)
        }
        dateIcon.snp.makeConstraints { make in
            make.centerY.equalTo(teamCountIcon)
            make.leading.equalTo(teamCountLabel.snp.trailing).offset(16)
            make.size.equalTo(14)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(teamCountIcon)
            make.leading.equalTo(dateIcon.snp.trailing).offset(6)
            make.bottom.equalToSuperview().offset(-14)
        }

        if tournament.status == .live {
            progressBar.backgroundColor = Theme.Color.surfaceElevated
            progressBar.layer.cornerRadius = 1.5
            progressFill.backgroundColor = Theme.Color.accent
            progressFill.layer.cornerRadius = 1.5
            addSubview(progressBar)
            progressBar.addSubview(progressFill)
            progressBar.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(14)
                make.trailing.equalToSuperview().offset(-14)
                make.bottom.equalToSuperview().offset(-6)
                make.height.equalTo(3)
            }
            progressFill.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.66)
            }
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
