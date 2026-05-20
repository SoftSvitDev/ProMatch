import UIKit
import SnapKit

final class TeamsViewController: UIViewController {
    private var teamsView: TeamsView { view as! TeamsView }
    private var allTeams: [Team] = []
    private var filteredTeams: [Team] = []
    private var searchQuery: String = ""

    override func loadView() { view = TeamsView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissal()
        teamsView.collectionView.register(TeamCardCell.self, forCellWithReuseIdentifier: TeamCardCell.reuseId)
        teamsView.collectionView.dataSource = self
        teamsView.collectionView.delegate = self
        teamsView.collectionView.keyboardDismissMode = .onDrag
        teamsView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        teamsView.searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .teamsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .tournamentsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    @objc private func reload() {
        allTeams = DataStore.shared.teams
        applyFilter()
    }

    @objc private func searchChanged() {
        searchQuery = teamsView.searchField.text ?? ""
        applyFilter()
    }

    private func applyFilter() {
        if searchQuery.isEmpty {
            filteredTeams = allTeams
        } else {
            let q = searchQuery.lowercased()
            filteredTeams = allTeams.filter {
                $0.name.lowercased().contains(q) || $0.city.lowercased().contains(q)
            }
        }
        teamsView.countLabel.text = "\(filteredTeams.count) \(filteredTeams.count == 1 ? "team" : "teams")"
        teamsView.emptyState.isHidden = !allTeams.isEmpty
        teamsView.collectionView.reloadData()
    }

    @objc private func addTapped() {
        let vc = CreateTeamViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TeamsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { filteredTeams.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCardCell.reuseId, for: indexPath) as! TeamCardCell
        let team = filteredTeams[indexPath.item]
        let record = team.record(in: DataStore.shared.tournaments)
        cell.configure(with: team, wins: record.wins, draws: record.draws, losses: record.losses)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 160)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PlayerCardViewController(teamId: filteredTeams[indexPath.item].id)
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let team = filteredTeams[indexPath.item]
        return UIContextMenuConfiguration(identifier: team.id as NSUUID, previewProvider: nil) { [weak self] _ in
            let delete = UIAction(title: "Delete team", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.confirmDelete(team: team)
            }
            return UIMenu(title: team.name, children: [delete])
        }
    }

    private func confirmDelete(team: Team) {
        let blockers = DataStore.shared.tournamentsBlockingDeletion(of: team.id)
        let baseMessage = "This will permanently remove \(team.name) and its roster."
        let warning: String
        if blockers.isEmpty {
            warning = baseMessage
        } else {
            let list = blockers.joined(separator: ", ")
            warning = baseMessage + "\n\nIt is also participating in: \(list). Played matches will be removed."
        }
        let alert = UIAlertController(title: "Delete \(team.name)?", message: warning, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            DataStore.shared.deleteTeam(id: team.id)
        })
        present(alert, animated: true)
    }
}
