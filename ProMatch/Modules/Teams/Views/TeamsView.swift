import UIKit
import SnapKit

final class TeamsView: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = .white
        l.text = "My Teams"
        return l
    }()

    let settingsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)), for: .normal)
        b.tintColor = .white
        b.backgroundColor = Theme.Color.surface
        b.layer.cornerRadius = 18
        return b
    }()

    let searchBar: UIView = {
        let container = UIView()
        container.backgroundColor = Theme.Color.surface
        container.layer.cornerRadius = 12
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = Theme.Color.textTertiary
        icon.contentMode = .scaleAspectFit
        let tf = PaddedTextField()
        tf.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search teams...",
            attributes: [.foregroundColor: Theme.Color.textTertiary, .font: Theme.Font.regular(14)])
        tf.font = Theme.Font.regular(14)
        tf.textColor = .white
        container.addSubview(icon)
        container.addSubview(tf)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        tf.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview()
        }
        return container
    }()

    let countLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.medium(13)
        l.textColor = Theme.Color.textSecondary
        return l
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return cv
    }()

    let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = Theme.Color.accent
        b.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        b.tintColor = .black
        b.layer.cornerRadius = 28
        b.layer.shadowColor = Theme.Color.accent.cgColor
        b.layer.shadowOpacity = 0.4
        b.layer.shadowRadius = 12
        b.layer.shadowOffset = .zero
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        [titleLabel, settingsButton, searchBar, countLabel, collectionView, addButton].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeTop).offset(8)
            make.leading.equalToSuperview().offset(24)
        }
        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(36)
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeBottom).offset(-24)
            make.size.equalTo(56)
        }
    }
}

final class TeamCardCell: UICollectionViewCell {
    static let reuseId = "TeamCardCell"

    private let badge: TeamBadge
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    private let formLine = UIView()
    private let formBars: [(UIView, UILabel)]

    override init(frame: CGRect) {
        badge = TeamBadge(initials: "  ", color: Theme.Color.pillRed, size: 40, fontSize: 16)
        formBars = []
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private let winBar = UIView()
    private let drawBar = UIView()
    private let lossBar = UIView()
    private let winLabel = UILabel()
    private let drawLabel = UILabel()
    private let lossLabel = UILabel()

    private func setupUI() {
        contentView.backgroundColor = Theme.Color.surface
        contentView.layer.cornerRadius = Theme.Metric.cardRadius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Theme.Color.stroke.withAlphaComponent(0.5).cgColor

        nameLabel.font = Theme.Font.bold(16)
        nameLabel.textColor = .white
        countLabel.font = Theme.Font.regular(12)
        countLabel.textColor = Theme.Color.textSecondary

        for (bar, color) in [(winBar, Theme.Color.win), (drawBar, Theme.Color.draw), (lossBar, Theme.Color.loss)] {
            bar.backgroundColor = color
            bar.layer.cornerRadius = 2
        }

        for (label, color) in [(winLabel, Theme.Color.win), (drawLabel, Theme.Color.draw), (lossLabel, Theme.Color.loss)] {
            label.font = Theme.Font.bold(10)
            label.textColor = color
        }

        [badge, nameLabel, countLabel, winBar, drawBar, lossBar, winLabel, drawLabel, lossLabel].forEach {
            contentView.addSubview($0)
        }

        badge.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(14)
            make.size.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(badge.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(14)
        }

        winBar.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.height.equalTo(3)
        }
        drawBar.snp.makeConstraints { make in
            make.top.equalTo(winBar)
            make.leading.equalTo(winBar.snp.trailing).offset(2)
            make.height.equalTo(3)
        }
        lossBar.snp.makeConstraints { make in
            make.top.equalTo(winBar)
            make.leading.equalTo(drawBar.snp.trailing).offset(2)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(3)
        }

        winLabel.snp.makeConstraints { make in
            make.top.equalTo(winBar.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
        }
        drawLabel.snp.makeConstraints { make in
            make.top.equalTo(winLabel)
            make.leading.equalTo(winLabel.snp.trailing).offset(12)
        }
        lossLabel.snp.makeConstraints { make in
            make.top.equalTo(winLabel)
            make.leading.equalTo(drawLabel.snp.trailing).offset(12)
        }
    }

    func configure(with team: Team) {
        badge.backgroundColor = team.color
        badge.label.text = team.initials
        nameLabel.text = team.name
        countLabel.text = team.playerCountText
        winLabel.text = "W\(team.wins)"
        drawLabel.text = "D\(team.draws)"
        lossLabel.text = "L\(team.losses)"
        let total = max(team.wins + team.draws + team.losses, 1)
        winBar.snp.remakeConstraints { make in
            make.top.equalTo(contentView.subviews[3].snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.height.equalTo(3)
            make.width.equalTo(CGFloat(team.wins) / CGFloat(total) * 110)
        }
        drawBar.snp.remakeConstraints { make in
            make.top.equalTo(winBar)
            make.leading.equalTo(winBar.snp.trailing).offset(2)
            make.height.equalTo(3)
            make.width.equalTo(CGFloat(team.draws) / CGFloat(total) * 110)
        }
        lossBar.snp.remakeConstraints { make in
            make.top.equalTo(winBar)
            make.leading.equalTo(drawBar.snp.trailing).offset(2)
            make.height.equalTo(3)
            make.width.equalTo(CGFloat(team.losses) / CGFloat(total) * 110)
        }
    }
}
