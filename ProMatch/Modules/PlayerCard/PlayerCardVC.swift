import UIKit
import SnapKit

final class PlayerCardViewController: UIViewController {
    private var playerCardView: PlayerCardView { view as! PlayerCardView }
    private let team: Team

    init(team: Team) {
        self.team = team
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = PlayerCardView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        playerCardView.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        playerCardView.addButton.addTarget(self, action: #selector(addPlayer), for: .touchUpInside)
    }

    private func configure() {
        playerCardView.nameLabel.text = team.name
        let foundedText = team.foundedYear.map { " · Est. \($0)" } ?? ""
        playerCardView.subtitleLabel.text = team.city + foundedText
        if let logoLabel = playerCardView.logoView.subviews.first as? UILabel {
            logoLabel.text = team.initials
        }
        playerCardView.logoView.backgroundColor = team.color
        playerCardView.winsBox.valueLabel.text = "\(team.wins)"
        playerCardView.drawsBox.valueLabel.text = "\(team.draws)"
        playerCardView.lossesBox.valueLabel.text = "\(team.losses)"
        playerCardView.playerCountLabel.text = "\(team.players.count) players"

        playerCardView.playersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for p in team.players {
            let row = PlayerRowView(player: p)
            playerCardView.playersStack.addArrangedSubview(row)
        }
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func addPlayer() {
        let vc = AddPlayerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
