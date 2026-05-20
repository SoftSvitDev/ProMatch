import UIKit
import SnapKit

final class ScoreEntryViewController: UIViewController {
    private var entryView: ScoreEntryView { view as! ScoreEntryView }
    private let tournamentId: UUID
    private let matchId: UUID

    private var homeTeam: Team!
    private var awayTeam: Team!
    private var homeScore: Int = 0
    private var awayScore: Int = 0
    /// Working scorer list (one entry per goal).
    private var goals: [Goal] = []

    private weak var homeStepper: ScoreStepper?
    private weak var awayStepper: ScoreStepper?
    private weak var homeScorersStack: UIStackView?
    private weak var awayScorersStack: UIStackView?

    init(tournamentId: UUID, matchId: UUID) {
        self.tournamentId = tournamentId
        self.matchId = matchId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = ScoreEntryView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let tournament = DataStore.shared.tournament(id: tournamentId),
              let match = tournament.matches.first(where: { $0.id == matchId }),
              let home = DataStore.shared.team(id: match.homeTeamId),
              let away = DataStore.shared.team(id: match.awayTeamId)
        else {
            navigationController?.popViewController(animated: true)
            return
        }
        self.homeTeam = home
        self.awayTeam = away
        self.homeScore = match.homeScore ?? 0
        self.awayScore = match.awayScore ?? 0
        self.goals = match.goals

        entryView.navBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        entryView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        build()
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    private func build() {
        let stack = entryView.contentStack

        let header = MatchupHeaderView(homeTeam: homeTeam, awayTeam: awayTeam)
        stack.addArrangedSubview(header)

        let scoreHeader = SectionHeaderLabel("Match Score")
        stack.addArrangedSubview(scoreHeader)
        stack.setCustomSpacing(8, after: scoreHeader)

        let scoreRow = ScoreStepperRow(homeInitial: homeScore, awayInitial: awayScore)
        homeStepper = scoreRow.homeStepper
        awayStepper = scoreRow.awayStepper
        scoreRow.homeStepper.onChange = { [weak self] v in
            self?.homeScore = v
            self?.clampGoals(for: .home)
        }
        scoreRow.awayStepper.onChange = { [weak self] v in
            self?.awayScore = v
            self?.clampGoals(for: .away)
        }
        stack.addArrangedSubview(scoreRow)

        // Home scorers
        stack.setCustomSpacing(12, after: scoreRow)
        let homeHeader = SectionHeaderLabel("\(homeTeam.name) Scorers")
        stack.addArrangedSubview(homeHeader)
        stack.setCustomSpacing(8, after: homeHeader)
        let homeStack = UIStackView()
        homeStack.axis = .vertical
        homeStack.spacing = 8
        stack.addArrangedSubview(homeStack)
        self.homeScorersStack = homeStack
        let homeAdd = AddScorerButton()
        homeAdd.addTarget(self, action: #selector(addHomeScorerTapped), for: .touchUpInside)
        stack.addArrangedSubview(homeAdd)

        // Away scorers
        stack.setCustomSpacing(12, after: homeAdd)
        let awayHeader = SectionHeaderLabel("\(awayTeam.name) Scorers")
        stack.addArrangedSubview(awayHeader)
        stack.setCustomSpacing(8, after: awayHeader)
        let awayStack = UIStackView()
        awayStack.axis = .vertical
        awayStack.spacing = 8
        stack.addArrangedSubview(awayStack)
        self.awayScorersStack = awayStack
        let awayAdd = AddScorerButton()
        awayAdd.addTarget(self, action: #selector(addAwayScorerTapped), for: .touchUpInside)
        stack.addArrangedSubview(awayAdd)

        rebuildScorerRows()
    }

    private enum Side { case home, away }

    private func rebuildScorerRows() {
        rebuildScorerRows(for: .home, team: homeTeam, stack: homeScorersStack)
        rebuildScorerRows(for: .away, team: awayTeam, stack: awayScorersStack)
    }

    private func rebuildScorerRows(for side: Side, team: Team, stack: UIStackView?) {
        guard let stack else { return }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let teamId = team.id
        let teamGoals = goals.filter { $0.teamId == teamId }
        // Preserve insertion order of distinct players.
        var order: [UUID] = []
        var seen = Set<UUID>()
        for g in teamGoals where !seen.contains(g.playerId) {
            seen.insert(g.playerId); order.append(g.playerId)
        }

        if order.isEmpty {
            stack.addArrangedSubview(makeEmptyScorersHint(roster: team.players))
            return
        }
        for pid in order {
            guard let player = team.players.first(where: { $0.id == pid }) else { continue }
            let count = teamGoals.filter { $0.playerId == pid }.count
            let row = ScorerRowView(player: player, initialCount: count)
            row.countStepper.onChange = { [weak self] new in
                self?.setGoalCount(playerId: pid, teamId: teamId, count: new)
            }
            row.removeButton.addAction(UIAction { [weak self] _ in
                self?.setGoalCount(playerId: pid, teamId: teamId, count: 0)
                self?.rebuildScorerRows()
            }, for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
    }

    private func makeEmptyScorersHint(roster: [Player]) -> UIView {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = Theme.Font.regular(13)
        l.textColor = Theme.Color.textTertiary
        l.textAlignment = .center
        l.text = roster.isEmpty ? "No players in this team yet" : "No scorers added"
        return l
    }

    private func setGoalCount(playerId: UUID, teamId: UUID, count: Int) {
        let teamScore = teamId == homeTeam.id ? homeScore : awayScore
        let otherPlayerGoals = goals.filter { $0.teamId == teamId && $0.playerId != playerId }.count
        let maxAllowed = max(0, teamScore - otherPlayerGoals)
        let clamped = max(0, min(count, maxAllowed))

        goals.removeAll { $0.teamId == teamId && $0.playerId == playerId }
        for _ in 0..<clamped {
            goals.append(Goal(playerId: playerId, teamId: teamId))
        }
    }

    private func clampGoals(for side: Side) {
        let teamId = side == .home ? homeTeam.id : awayTeam.id
        let maxScore = side == .home ? homeScore : awayScore
        let teamGoals = goals.filter { $0.teamId == teamId }
        if teamGoals.count <= maxScore { return }
        var kept: [Goal] = []
        var byPlayer: [UUID: Int] = [:]
        for g in teamGoals {
            if kept.count >= maxScore { break }
            byPlayer[g.playerId, default: 0] += 1
            kept.append(g)
        }
        goals.removeAll { $0.teamId == teamId }
        goals.append(contentsOf: kept)
        rebuildScorerRows()
    }

    @objc private func addHomeScorerTapped() { presentScorerPicker(team: homeTeam) }
    @objc private func addAwayScorerTapped() { presentScorerPicker(team: awayTeam) }

    private func presentScorerPicker(team: Team) {
        let teamId = team.id
        let teamScore = teamId == homeTeam.id ? homeScore : awayScore
        let assigned = goals.filter { $0.teamId == teamId }.count
        guard teamScore > assigned else {
            let msg: String
            if teamScore == 0 {
                msg = "No goals to attribute yet. Increase the score first."
            } else {
                msg = "All \(teamScore) goals are already attributed. Increase the score to add another scorer."
            }
            showInfo(msg)
            return
        }
        if team.players.isEmpty {
            showInfo("This team has no players yet. Add players first to attribute goals.")
            return
        }
        let sheet = UIAlertController(title: "Add scorer for \(team.name)", message: nil, preferredStyle: .actionSheet)
        for player in team.players {
            let current = goals.filter { $0.teamId == teamId && $0.playerId == player.id }.count
            let title = current > 0 ? "\(player.fullName) (+1 to \(current))" : player.fullName
            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.goals.append(Goal(playerId: player.id, teamId: teamId))
                self?.rebuildScorerRows()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(sheet, animated: true)
    }

    private func showInfo(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func save() {
        guard let tournament = DataStore.shared.tournament(id: tournamentId) else { return }
        if tournament.format == .knockout && homeScore == awayScore {
            showInfo("Knockout matches need a winner. Enter a non-tied score.")
            return
        }
        DataStore.shared.recordMatch(tournamentId: tournamentId, matchId: matchId,
                                     home: homeScore, away: awayScore, goals: goals)
        navigationController?.popViewController(animated: true)
    }
}
