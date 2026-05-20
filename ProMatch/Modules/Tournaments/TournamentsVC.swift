import UIKit
import SnapKit

final class TournamentsViewController: UIViewController {
    private var tournamentsView: TournamentsView { view as! TournamentsView }
    private var allTournaments: [Tournament] = []
    private var searchQuery: String = ""

    override func loadView() { view = TournamentsView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissal()
        tournamentsView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        tournamentsView.searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        tournamentsView.scrollView.keyboardDismissMode = .onDrag
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .tournamentsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .teamsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    @objc private func searchChanged() {
        searchQuery = tournamentsView.searchField.text ?? ""
        render()
    }

    @objc private func reload() {
        allTournaments = DataStore.shared.tournaments
        render()
    }

    private func render() {
        tournamentsView.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let filtered: [Tournament]
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            filtered = allTournaments
        } else {
            let q = searchQuery.lowercased()
            filtered = allTournaments.filter {
                $0.name.lowercased().contains(q) || $0.format.rawValue.lowercased().contains(q)
            }
        }

        let hasAnyTournaments = !allTournaments.isEmpty
        tournamentsView.emptyState.isHidden = hasAnyTournaments

        if hasAnyTournaments && filtered.isEmpty {
            let label = UILabel()
            label.text = "No tournaments match \"\(searchQuery)\""
            label.font = Theme.Font.regular(14)
            label.textColor = Theme.Color.textSecondary
            label.textAlignment = .center
            label.numberOfLines = 0
            tournamentsView.contentStack.addArrangedSubview(label)
            return
        }

        let live = filtered.filter { $0.status == .live }
        let upcoming = filtered.filter { $0.status == .scheduled }
        let completed = filtered.filter { $0.status == .completed }

        func add(_ section: String, _ items: [Tournament], color: UIColor) {
            guard !items.isEmpty else { return }
            let header = SectionLabelView(section, color: color)
            tournamentsView.contentStack.addArrangedSubview(header)
            tournamentsView.contentStack.setCustomSpacing(8, after: header)
            for t in items {
                let row = TournamentRowView(tournament: t)
                row.tournamentId = t.id
                row.addTarget(self, action: #selector(tournamentTapped(_:)), for: .touchUpInside)
                let interaction = UIContextMenuInteraction(delegate: self)
                row.addInteraction(interaction)
                tournamentsView.contentStack.addArrangedSubview(row)
                tournamentsView.contentStack.setCustomSpacing(16, after: row)
            }
        }

        add("Live Now", live, color: Theme.Color.accent)
        add("Upcoming", upcoming, color: Theme.Color.textSecondary)
        add("Completed", completed, color: Theme.Color.textSecondary)
    }

    @objc private func tournamentTapped(_ sender: TournamentRowView) {
        guard let id = sender.tournamentId else { return }
        let vc = TournamentDetailViewController(tournamentId: id)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func addTapped() {
        if DataStore.shared.teams.count < 2 {
            let alert = UIAlertController(
                title: "Need 2+ Teams",
                message: "Create at least two teams before starting a tournament.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let vc = NewTournamentViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func confirmDelete(tournament: Tournament) {
        let alert = UIAlertController(
            title: "Delete \(tournament.name)?",
            message: "All matches and results for this tournament will be removed.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            DataStore.shared.deleteTournament(id: tournament.id)
        })
        present(alert, animated: true)
    }
}

extension TournamentsViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let row = interaction.view as? TournamentRowView,
              let id = row.tournamentId,
              let tournament = DataStore.shared.tournament(id: id) else { return nil }
        return UIContextMenuConfiguration(identifier: id as NSUUID, previewProvider: nil) { [weak self] _ in
            let delete = UIAction(title: "Delete tournament", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.confirmDelete(tournament: tournament)
            }
            return UIMenu(title: tournament.name, children: [delete])
        }
    }
}
