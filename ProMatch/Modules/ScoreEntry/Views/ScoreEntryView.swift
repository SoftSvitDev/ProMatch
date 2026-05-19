import UIKit
import SnapKit

final class ScoreEntryView: UIView {
    let navBar = NavBarView(title: "Enter Score")

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
        return s
    }()

    let saveButton = PrimaryButton(title: "Save Match", style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        [navBar, scrollView, saveButton].forEach { addSubview($0) }
        scrollView.addSubview(contentStack)
    }

    private func setupConstraints() {
        navBar.snp.makeConstraints { make in
            make.top.equalTo(safeTop)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-12)
        }
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.width.equalTo(scrollView).offset(-48)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeBottom).offset(-16)
            make.height.equalTo(Theme.Metric.buttonHeight)
        }
    }
}

final class MatchupHeaderView: UIView {
    init(homeTeam: Team, awayTeam: Team) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        let homeBadge = TeamBadge(initials: homeTeam.initials, color: homeTeam.color, size: 56, fontSize: 22)
        let awayBadge = TeamBadge(initials: awayTeam.initials, color: awayTeam.color, size: 56, fontSize: 22)
        if let img = DataStore.shared.teamLogo(for: homeTeam) {
            homeBadge.imageView.image = img
            homeBadge.imageView.isHidden = false
            homeBadge.label.isHidden = true
        }
        if let img = DataStore.shared.teamLogo(for: awayTeam) {
            awayBadge.imageView.image = img
            awayBadge.imageView.isHidden = false
            awayBadge.label.isHidden = true
        }

        let homeName = UILabel()
        homeName.text = homeTeam.name
        homeName.font = Theme.Font.semibold(13)
        homeName.textColor = Theme.Color.textPrimary
        homeName.textAlignment = .center
        homeName.numberOfLines = 2

        let awayName = UILabel()
        awayName.text = awayTeam.name
        awayName.font = Theme.Font.semibold(13)
        awayName.textColor = Theme.Color.textPrimary
        awayName.textAlignment = .center
        awayName.numberOfLines = 2

        let vs = UILabel()
        vs.text = "VS"
        vs.font = Theme.Font.bold(13)
        vs.textColor = Theme.Color.textTertiary
        vs.textAlignment = .center

        [homeBadge, homeName, vs, awayBadge, awayName].forEach { addSubview($0) }

        homeBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(36)
            make.size.equalTo(56)
        }
        homeName.snp.makeConstraints { make in
            make.top.equalTo(homeBadge.snp.bottom).offset(8)
            make.centerX.equalTo(homeBadge)
            make.width.equalTo(96)
            make.bottom.equalToSuperview().offset(-14)
        }
        vs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(homeBadge)
        }
        awayBadge.snp.makeConstraints { make in
            make.top.equalTo(homeBadge)
            make.trailing.equalToSuperview().offset(-36)
            make.size.equalTo(56)
        }
        awayName.snp.makeConstraints { make in
            make.top.equalTo(awayBadge.snp.bottom).offset(8)
            make.centerX.equalTo(awayBadge)
            make.width.equalTo(96)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class ScoreStepperRow: UIView {
    let homeStepper: ScoreStepper
    let awayStepper: ScoreStepper

    init(homeInitial: Int, awayInitial: Int) {
        self.homeStepper = ScoreStepper(initial: homeInitial)
        self.awayStepper = ScoreStepper(initial: awayInitial)
        super.init(frame: .zero)

        let dash = UILabel()
        dash.text = "–"
        dash.font = Theme.Font.bold(28)
        dash.textColor = Theme.Color.textTertiary
        dash.textAlignment = .center

        addSubview(homeStepper)
        addSubview(dash)
        addSubview(awayStepper)

        homeStepper.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(awayStepper)
        }
        dash.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
        }
        awayStepper.snp.makeConstraints { make in
            make.leading.equalTo(dash.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(72) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class ScoreStepper: UIView {
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)
    let valueLabel = UILabel()
    var onChange: ((Int) -> Void)?
    private(set) var value: Int {
        didSet {
            valueLabel.text = "\(value)"
            onChange?(value)
        }
    }

    init(initial: Int) {
        self.value = max(0, initial)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        clipsToBounds = true

        minusButton.setImage(UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        plusButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        minusButton.tintColor = Theme.Color.textPrimary
        plusButton.tintColor = Theme.Color.textPrimary
        valueLabel.text = "\(value)"
        valueLabel.font = Theme.Font.bold(28)
        valueLabel.textColor = Theme.Color.accent
        valueLabel.textAlignment = .center

        addSubview(minusButton)
        addSubview(plusButton)
        addSubview(valueLabel)
        minusButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(48)
        }
        plusButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(48)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(minusButton.snp.trailing)
            make.trailing.equalTo(plusButton.snp.leading)
            make.top.bottom.equalToSuperview()
        }
        minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func minus() { if value > 0 { value -= 1 } }
    @objc private func plus() { if value < 99 { value += 1 } }

    func setValue(_ v: Int, notify: Bool = false) {
        if notify { value = max(0, v) }
        else {
            // silent update — bypass didSet by reassigning the label only
            valueLabel.text = "\(max(0, v))"
        }
    }
}

final class ScorerRowView: UIView {
    let nameLabel = UILabel()
    let countStepper: ScoreStepper
    let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.surfaceElevated
        v.layer.cornerRadius = 14
        return v
    }()
    let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(11)
        l.textColor = Theme.Color.textPrimary
        l.textAlignment = .center
        return l
    }()
    let removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = Theme.Color.textTertiary
        return b
    }()
    let playerId: UUID

    init(player: Player, initialCount: Int) {
        self.playerId = player.id
        self.countStepper = ScoreStepper(initial: initialCount)
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius

        nameLabel.text = player.fullName
        nameLabel.font = Theme.Font.semibold(14)
        nameLabel.textColor = Theme.Color.textPrimary
        initialsLabel.text = player.initials

        addSubview(avatarView)
        avatarView.addSubview(initialsLabel)
        addSubview(nameLabel)
        addSubview(countStepper)
        addSubview(removeButton)

        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(countStepper.snp.leading).offset(-8)
        }
        countStepper.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(removeButton.snp.leading).offset(-6)
            make.width.equalTo(108)
            make.height.equalTo(36)
        }
        removeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        snp.makeConstraints { $0.height.equalTo(56) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class AddScorerButton: UIControl {
    init() {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        layer.borderColor = Theme.Color.stroke.cgColor
        layer.borderWidth = 1
        let icon = UIImageView(image: UIImage(systemName: "plus.circle"))
        icon.tintColor = Theme.Color.accent
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = "Add scorer"
        label.font = Theme.Font.semibold(14)
        label.textColor = Theme.Color.accent
        addSubview(icon)
        addSubview(label)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(48) }
    }
    required init?(coder: NSCoder) { fatalError() }
}
