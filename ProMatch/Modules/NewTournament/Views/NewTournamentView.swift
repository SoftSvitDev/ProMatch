import UIKit
import SnapKit

final class NewTournamentView: UIView {
    let navBar = NavBarView(title: "New Tournament")

    let stepSubtitle: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(12)
        l.textColor = Theme.Color.textSecondary
        return l
    }()

    let progressStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        return s
    }()

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()
    let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.alignment = .fill
        return s
    }()

    let continueButton = PrimaryButton(title: "Continue", style: .disabled)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configureProgress(step: Int, totalSteps: Int) {
        progressStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<totalSteps {
            let bar = UIView()
            bar.backgroundColor = i < step ? Theme.Color.accent : Theme.Color.surfaceElevated
            bar.layer.cornerRadius = 2
            bar.snp.makeConstraints { $0.height.equalTo(4) }
            progressStack.addArrangedSubview(bar)
        }
        stepSubtitle.text = "Step \(step) of \(totalSteps)"
    }

    private func setupUI() {
        [navBar, stepSubtitle, progressStack, scrollView, continueButton].forEach { addSubview($0) }
        scrollView.addSubview(contentStack)
    }

    private func setupConstraints() {
        navBar.snp.makeConstraints { make in
            make.top.equalTo(safeTop)
            make.leading.trailing.equalToSuperview()
        }
        stepSubtitle.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(-4)
            make.leading.equalToSuperview().offset(64)
        }
        progressStack.snp.makeConstraints { make in
            make.top.equalTo(stepSubtitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(4)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(progressStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-16)
        }
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.width.equalTo(scrollView).offset(-48)
        }
        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeBottom).offset(-16)
            make.height.equalTo(Theme.Metric.buttonHeight)
        }
    }
}

final class FormatOptionRow: UIControl {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let radio = UIView()
    var format: Tournament.Format = .roundRobin
    var isOn: Bool = false {
        didSet {
            if isOn {
                radio.backgroundColor = Theme.Color.accent
                radio.layer.borderColor = Theme.Color.accent.cgColor
            } else {
                radio.backgroundColor = .clear
                radio.layer.borderColor = Theme.Color.textTertiary.cgColor
            }
        }
    }

    init(symbol: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        iconView.image = UIImage(systemName: symbol)
        iconView.tintColor = Theme.Color.textSecondary
        iconView.contentMode = .scaleAspectFit
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(15)
        titleLabel.textColor = Theme.Color.textPrimary
        subtitleLabel.text = subtitle
        subtitleLabel.font = Theme.Font.regular(12)
        subtitleLabel.textColor = Theme.Color.textSecondary
        radio.layer.borderColor = Theme.Color.textTertiary.cgColor
        radio.layer.borderWidth = 1.5
        radio.layer.cornerRadius = 10

        [iconView, titleLabel, subtitleLabel, radio].forEach { addSubview($0) }
        snp.makeConstraints { $0.height.equalTo(64) }
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(13)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        radio.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class TeamSelectRow: UIControl {
    var teamId: UUID?
    let badge: TeamBadge
    let nameLabel = UILabel()
    let detailLabel = UILabel()
    let radio = UIView()
    var isOn = false { didSet { updateRadio() } }
    var isEligible: Bool = true { didSet { applyEligibility() } }

    private func applyEligibility() {
        alpha = isEligible ? 1.0 : 0.5
        radio.isHidden = !isEligible
    }

    init(team: Team) {
        self.teamId = team.id
        badge = TeamBadge(initials: team.initials, color: team.color, size: 32, fontSize: 13)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        nameLabel.text = team.name
        nameLabel.font = Theme.Font.bold(15)
        nameLabel.textColor = Theme.Color.textPrimary

        detailLabel.text = "\(team.playerCountText) · \(team.city)"
        detailLabel.font = Theme.Font.regular(12)
        detailLabel.textColor = Theme.Color.textSecondary

        radio.layer.borderColor = Theme.Color.textTertiary.cgColor
        radio.layer.borderWidth = 1.5
        radio.layer.cornerRadius = 10

        [badge, nameLabel, detailLabel, radio].forEach { addSubview($0) }
        snp.makeConstraints { $0.height.equalTo(60) }
        badge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(badge.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        radio.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func updateRadio() {
        if isOn {
            radio.backgroundColor = Theme.Color.accent
            radio.layer.borderColor = Theme.Color.accent.cgColor
        } else {
            radio.backgroundColor = .clear
            radio.layer.borderColor = Theme.Color.textTertiary.cgColor
        }
    }
}

final class RuleStepperRow: UIView {
    let titleLabel = UILabel()
    let stepper: NumberStepper

    init(title: String, initial: Int) {
        stepper = NumberStepper(initial: initial)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        titleLabel.text = title
        titleLabel.font = Theme.Font.regular(14)
        titleLabel.textColor = Theme.Color.textPrimary

        let valueWrap = UIView()
        valueWrap.backgroundColor = .clear
        valueWrap.addSubview(stepper)
        stepper.snp.makeConstraints { $0.edges.equalToSuperview() }

        addSubview(titleLabel)
        addSubview(valueWrap)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        valueWrap.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(40)
        }
        snp.makeConstraints { $0.height.equalTo(56) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class TiebreakerRow: UIControl {
    var tiebreaker: Tournament.Tiebreaker?
    let titleLabel = UILabel()
    let check = UIImageView()
    var isSelected2: Bool = false {
        didSet {
            check.isHidden = !isSelected2
            backgroundColor = isSelected2 ? Theme.Color.accent.withAlphaComponent(0.18) : Theme.Color.surface
            layer.borderColor = isSelected2 ? Theme.Color.accent.cgColor : UIColor.clear.cgColor
            layer.borderWidth = isSelected2 ? 1.5 : 0
            titleLabel.textColor = isSelected2 ? Theme.Color.accent : Theme.Color.textPrimary
        }
    }

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        titleLabel.text = title
        titleLabel.font = Theme.Font.semibold(14)
        titleLabel.textColor = Theme.Color.textPrimary
        check.image = UIImage(systemName: "checkmark")
        check.tintColor = Theme.Color.accent
        check.isHidden = true
        addSubview(titleLabel)
        addSubview(check)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        check.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        snp.makeConstraints { $0.height.equalTo(46) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class ReviewSummaryView: UIView {
    init(rows: [(String, String)]) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)) }

        for (i, (k, v)) in rows.enumerated() {
            let row = UIView()
            let key = UILabel()
            key.text = k; key.font = Theme.Font.regular(13); key.textColor = Theme.Color.textSecondary
            let val = UILabel()
            val.text = v; val.font = Theme.Font.semibold(13); val.textColor = Theme.Color.textPrimary; val.textAlignment = .right
            row.addSubview(key)
            row.addSubview(val)
            key.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            val.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            row.snp.makeConstraints { $0.height.equalTo(40) }
            stack.addArrangedSubview(row)

            if i < rows.count - 1 {
                let line = UIView()
                line.backgroundColor = Theme.Color.divider
                line.snp.makeConstraints { $0.height.equalTo(0.5) }
                stack.addArrangedSubview(line)
            }
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
