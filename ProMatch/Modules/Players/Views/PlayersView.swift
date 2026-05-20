import UIKit
import SnapKit

final class PlayersView: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = Theme.Color.textPrimary
        l.text = "All Players"
        return l
    }()

    let searchField: PaddedTextField = {
        let tf = PaddedTextField()
        tf.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search players...",
            attributes: [.foregroundColor: Theme.Color.textTertiary,
                         .font: Theme.Font.regular(14)])
        tf.font = Theme.Font.regular(14)
        tf.textColor = Theme.Color.textPrimary
        tf.returnKeyType = .search
        return tf
    }()

    lazy var searchBar: UIView = {
        let container = UIView()
        container.backgroundColor = Theme.Color.surface
        container.layer.cornerRadius = 12
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = Theme.Color.textTertiary
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        container.addSubview(searchField)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        searchField.snp.makeConstraints { make in
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

    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tv.rowHeight = 68
        return tv
    }()

    let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = Theme.Color.accent
        b.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        b.tintColor = Theme.Color.onAccent
        b.layer.cornerRadius = 28
        return b
    }()

    let emptyState: UIView = {
        let v = UIView()
        v.isHidden = true
        let icon = UIImageView(image: UIImage(systemName: "person.2"))
        icon.tintColor = Theme.Color.textTertiary
        icon.contentMode = .scaleAspectFit
        let title = UILabel()
        title.text = "No players yet"
        title.font = Theme.Font.bold(17)
        title.textColor = Theme.Color.textPrimary
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Add players to your teams to see them here"
        subtitle.font = Theme.Font.regular(13)
        subtitle.textColor = Theme.Color.textSecondary
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
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
            make.leading.trailing.equalToSuperview()
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PlayersView {
    func setupUI() {
        [titleLabel, searchBar, countLabel, tableView, emptyState, addButton].forEach { addSubview($0) }
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeTop).offset(8)
            make.leading.equalToSuperview().offset(24)
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
        tableView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
        emptyState.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(safeBottom).offset(-24)
            make.size.equalTo(56)
        }
    }
}

final class PlayerListCell: UITableViewCell {
    static let reuseId = "PlayerListCell"

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        return v
    }()

    private let jerseyLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(15)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        return l
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        return v
    }()

    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(13)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.semibold(15)
        l.textColor = Theme.Color.textPrimary
        return l
    }()

    private let teamLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(12)
        l.textColor = Theme.Color.textSecondary
        return l
    }()

    private var positionPill: PillLabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(card)
        [jerseyLabel, avatarView, nameLabel, teamLabel].forEach { card.addSubview($0) }
        avatarView.addSubview(initialsLabel)

        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.trailing.equalToSuperview()
        }
        jerseyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.equalTo(22)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalTo(jerseyLabel.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }
        teamLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.trailing.lessThanOrEqualToSuperview().offset(-90)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(player: Player, teamName: String, teamColor: UIColor) {
        jerseyLabel.text = "\(player.jerseyNumber)"
        initialsLabel.text = player.initials
        avatarView.backgroundColor = teamColor
        nameLabel.text = player.fullName
        teamLabel.text = teamName

        positionPill?.removeFromSuperview()
        let pill = PillLabel(text: player.position.rawValue,
                             textColor: .black,
                             background: player.position.pillColor,
                             fontSize: 10)
        card.addSubview(pill)
        pill.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        positionPill = pill
    }
}
