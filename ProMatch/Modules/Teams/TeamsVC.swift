import UIKit
import SnapKit

final class TeamsViewController: UIViewController {
    private var teamsView: TeamsView { view as! TeamsView }
    private var teams: [Team] = SampleData.teams

    override func loadView() { view = TeamsView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        teamsView.collectionView.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseId)
        teamsView.collectionView.dataSource = self
        teamsView.collectionView.delegate = self
        teamsView.countLabel.text = "\(teams.count) teams"
        teamsView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    @objc private func addTapped() {
        let vc = CreateTeamViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TeamsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { teams.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCardCell.reuseId, for: indexPath) as! TeamCardCell
        cell.configure(with: teams[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 160)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PlayerCardViewController(team: teams[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
