import UIKit
import SnapKit

final class PlayersViewController: UIViewController {

    private var playersView: PlayersView { view as! PlayersView }

    private struct PlayerEntry {
        let player: Player
        let teamId: UUID
        let teamName: String
        let teamColor: UIColor
    }

    private var allEntries: [PlayerEntry] = []
    private var filteredEntries: [PlayerEntry] = []
    private var searchQuery: String = ""

    override func loadView() { view = PlayersView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissal()
        playersView.tableView.register(PlayerListCell.self, forCellReuseIdentifier: PlayerListCell.reuseId)
        playersView.tableView.dataSource = self
        playersView.tableView.delegate = self
        playersView.tableView.keyboardDismissMode = .onDrag
        playersView.searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        playersView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .teamsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    @objc private func reload() {
        allEntries = DataStore.shared.teams.flatMap { team in
            team.players.map { player in
                PlayerEntry(player: player,
                            teamId: team.id,
                            teamName: team.name,
                            teamColor: team.color)
            }
        }
        .sorted { $0.player.fullName.lowercased() < $1.player.fullName.lowercased() }
        applyFilter()
    }

    @objc private func searchChanged() {
        searchQuery = playersView.searchField.text ?? ""
        applyFilter()
    }

    private func applyFilter() {
        if searchQuery.isEmpty {
            filteredEntries = allEntries
        } else {
            let q = searchQuery.lowercased()
            filteredEntries = allEntries.filter {
                $0.player.fullName.lowercased().contains(q)
                || $0.teamName.lowercased().contains(q)
                || $0.player.position.rawValue.lowercased().contains(q)
            }
        }
        playersView.countLabel.text = "\(filteredEntries.count) \(filteredEntries.count == 1 ? "player" : "players")"
        playersView.emptyState.isHidden = !allEntries.isEmpty
        playersView.tableView.reloadData()
    }

    @objc private func addTapped() {
        let teams = DataStore.shared.teams
        if teams.isEmpty {
            let alert = UIAlertController(title: "No teams yet",
                                          message: "Create a team first to add players.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if teams.count == 1 {
            pushAddPlayer(teamId: teams[0].id)
            return
        }
        let sheet = UIAlertController(title: "Add player to…", message: nil, preferredStyle: .actionSheet)
        for team in teams {
            sheet.addAction(UIAlertAction(title: team.name, style: .default) { [weak self] _ in
                self?.pushAddPlayer(teamId: team.id)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func pushAddPlayer(teamId: UUID) {
        let vc = AddPlayerViewController(teamId: teamId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlayersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerListCell.reuseId, for: indexPath) as! PlayerListCell
        let entry = filteredEntries[indexPath.row]
        cell.configure(player: entry.player, teamName: entry.teamName, teamColor: entry.teamColor)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = filteredEntries[indexPath.row]
        let vc = PlayerDetailViewController(teamId: entry.teamId, playerId: entry.player.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
