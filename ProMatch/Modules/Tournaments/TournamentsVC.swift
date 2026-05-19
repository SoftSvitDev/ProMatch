import UIKit
import SnapKit

final class TournamentsViewController: UIViewController {
    private var tournamentsView: TournamentsView { view as! TournamentsView }

    override func loadView() { view = TournamentsView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
        tournamentsView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    private func build() {
        let stack = tournamentsView.contentStack
        let live = SampleData.tournaments.filter { $0.status == .live }
        let upcoming = SampleData.tournaments.filter { $0.status == .scheduled }
        let completed = SampleData.tournaments.filter { $0.status == .completed }

        func add(_ section: String, _ items: [Tournament], color: UIColor = Theme.Color.accent) {
            let header = SectionLabelView(section, color: color)
            stack.addArrangedSubview(header)
            stack.setCustomSpacing(8, after: header)
            for t in items {
                let row = TournamentRowView(tournament: t)
                row.addTarget(self, action: #selector(tournamentTapped), for: .touchUpInside)
                stack.addArrangedSubview(row)
                stack.setCustomSpacing(16, after: row)
            }
        }

        if !live.isEmpty { add("Live Now", live, color: Theme.Color.accent) }
        if !upcoming.isEmpty { add("Upcoming", upcoming, color: Theme.Color.textSecondary) }
        if !completed.isEmpty { add("Completed", completed, color: Theme.Color.textSecondary) }
    }

    @objc private func tournamentTapped() {
        let vc = TournamentDetailViewController(tournament: SampleData.tournaments[0])
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func addTapped() {
        let vc = NewTournamentViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
