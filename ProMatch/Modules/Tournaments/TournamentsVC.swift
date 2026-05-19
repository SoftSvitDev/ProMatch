import UIKit
import SnapKit

final class TournamentsViewController: UIViewController {
    private var tournamentsView: TournamentsView { view as! TournamentsView }

    override func loadView() { view = TournamentsView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tournamentsView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .tournamentsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload),
                                               name: .teamsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    @objc private func reload() {
        tournamentsView.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let tournaments = DataStore.shared.tournaments
        let live = tournaments.filter { $0.status == .live }
        let upcoming = tournaments.filter { $0.status == .scheduled }
        let completed = tournaments.filter { $0.status == .completed }

        tournamentsView.emptyState.isHidden = !tournaments.isEmpty

        func add(_ section: String, _ items: [Tournament], color: UIColor) {
            let header = SectionLabelView(section, color: color)
            tournamentsView.contentStack.addArrangedSubview(header)
            tournamentsView.contentStack.setCustomSpacing(8, after: header)
            for t in items {
                let row = TournamentRowView(tournament: t)
                row.tournamentId = t.id
                row.addTarget(self, action: #selector(tournamentTapped(_:)), for: .touchUpInside)
                tournamentsView.contentStack.addArrangedSubview(row)
                tournamentsView.contentStack.setCustomSpacing(16, after: row)
            }
        }

        if !live.isEmpty { add("Live Now", live, color: Theme.Color.accent) }
        if !upcoming.isEmpty { add("Upcoming", upcoming, color: Theme.Color.textSecondary) }
        if !completed.isEmpty { add("Completed", completed, color: Theme.Color.textSecondary) }
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
}
