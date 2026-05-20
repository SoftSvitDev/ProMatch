import UIKit
import SnapKit

final class PlayerCardViewController: UIViewController {
    private var playerCardView: PlayerCardView { view as! PlayerCardView }
    private let teamId: UUID

    init(teamId: UUID) {
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = PlayerCardView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        playerCardView.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        playerCardView.addButton.addTarget(self, action: #selector(addPlayer), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .teamsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .tournamentsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    @objc private func refresh() {
        guard let team = DataStore.shared.team(id: teamId) else { return }
        configure(team: team)
    }

    private func configure(team: Team) {
        playerCardView.nameLabel.text = team.name
        let foundedText = team.foundedYear.map { " · Est. \($0)" } ?? ""
        playerCardView.subtitleLabel.text = team.city + foundedText
        let logoImage = DataStore.shared.teamLogo(for: team)
        if let imageView = playerCardView.logoView.viewWithTag(99) as? UIImageView {
            imageView.image = logoImage
            imageView.isHidden = (logoImage == nil)
        }
        if let logoLabel = playerCardView.logoView.subviews.compactMap({ $0 as? UILabel }).first {
            logoLabel.text = team.initials
            logoLabel.isHidden = (logoImage != nil)
        }
        playerCardView.logoView.backgroundColor = team.color
        playerCardView.headerGradient.colors = [
            team.color,
            team.color.adjusted(brightness: 0.35)
        ]

        let record = team.record(in: DataStore.shared.tournaments)
        playerCardView.winsBox.valueLabel.text = "\(record.wins)"
        playerCardView.drawsBox.valueLabel.text = "\(record.draws)"
        playerCardView.lossesBox.valueLabel.text = "\(record.losses)"
        playerCardView.playerCountLabel.text = "\(team.players.count) \(team.players.count == 1 ? "player" : "players")"

        playerCardView.playersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if team.players.isEmpty {
            playerCardView.playersStack.addArrangedSubview(makeEmptyState())
        } else {
            for p in team.players {
                let row = PlayerRowView(player: p)
                let pid = p.id
                row.addAction(UIAction { [weak self] _ in
                    self?.openPlayer(playerId: pid)
                }, for: .touchUpInside)
                playerCardView.playersStack.addArrangedSubview(row)
            }
        }
    }

    private func openPlayer(playerId: UUID) {
        let vc = PlayerDetailViewController(teamId: teamId, playerId: playerId)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func makeEmptyState() -> UIView {
        let v = UIView()
        let l = UILabel()
        l.text = "No players yet — tap + Add to start your roster"
        l.font = Theme.Font.regular(13)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        v.addSubview(l)
        l.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        return v
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func addPlayer() {
        let vc = AddPlayerViewController(teamId: teamId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIColor {
    func adjusted(brightness: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(0, min(1, b * brightness)), alpha: a)
    }
}

final class PlayerDetailViewController: UIViewController {
    private var detailView: PlayerDetailView { view as! PlayerDetailView }
    private let teamId: UUID
    private let playerId: UUID

    init(teamId: UUID, playerId: UUID) {
        self.teamId = teamId
        self.playerId = playerId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = PlayerDetailView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.navBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        detailView.deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .teamsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    @objc private func refresh() {
        guard let team = DataStore.shared.team(id: teamId),
              let player = team.players.first(where: { $0.id == playerId }) else {
            navigationController?.popViewController(animated: true)
            return
        }
        detailView.configure(player: player, team: team)
    }

    @objc private func back() { navigationController?.popViewController(animated: true) }

    @objc private func deleteTapped() {
        guard let team = DataStore.shared.team(id: teamId),
              let player = team.players.first(where: { $0.id == playerId }) else { return }
        let alert = UIAlertController(
            title: "Delete \(player.fullName)?",
            message: "This will remove the player from \(team.name). This cannot be undone.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            DataStore.shared.removePlayer(playerId: self.playerId, fromTeam: self.teamId)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
