import UIKit
import SnapKit

final class TournamentDetailViewController: UIViewController {
    private let tournamentId: UUID
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let navBar: NavBarView
    private let statusPill: PillLabel
    private let subtitle = UILabel()
    private let teamsBox = StatBox(color: Theme.Color.accent, title: "Teams")
    private let playedBox = StatBox(color: Theme.Color.accent, title: "Played")
    private let remainingBox = StatBox(color: Theme.Color.accent, title: "Remaining")
    private let tabs = SegmentedTabsView(items: ["Standings", "Matches", "Scorers"])
    private let tabContainer = UIView()

    init(tournamentId: UUID) {
        self.tournamentId = tournamentId
        let name = DataStore.shared.tournament(id: tournamentId)?.name ?? "Tournament"
        self.navBar = NavBarView(title: name)
        self.statusPill = PillLabel(text: "", textColor: .clear, background: .clear, fontSize: 11)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        subtitle.font = Theme.Font.regular(13)
        subtitle.textColor = Theme.Color.textSecondary

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        [navBar, statusPill, subtitle, teamsBox, playedBox, remainingBox, tabs, tabContainer].forEach {
            contentView.addSubview($0)
        }

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeTop)
            make.leading.trailing.equalToSuperview()
        }
        statusPill.snp.makeConstraints { make in
            make.centerY.equalTo(navBar)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(-4)
            make.leading.equalToSuperview().offset(64)
        }
        teamsBox.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(playedBox)
            make.height.equalTo(70)
        }
        playedBox.snp.makeConstraints { make in
            make.top.equalTo(teamsBox)
            make.leading.equalTo(teamsBox.snp.trailing).offset(8)
            make.width.equalTo(remainingBox)
            make.height.equalTo(70)
        }
        remainingBox.snp.makeConstraints { make in
            make.top.equalTo(teamsBox)
            make.leading.equalTo(playedBox.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(70)
        }
        tabs.snp.makeConstraints { make in
            make.top.equalTo(teamsBox.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
        tabContainer.snp.makeConstraints { make in
            make.top.equalTo(tabs.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-32)
        }

        navBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        tabs.onChange = { [weak self] _ in self?.refresh() }
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .tournamentsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: .teamsDidChange, object: nil)
        refresh()
    }

    @objc private func back() { navigationController?.popViewController(animated: true) }

    @objc private func refresh() {
        guard let t = DataStore.shared.tournament(id: tournamentId) else { return }
        subtitle.text = t.format.rawValue
        teamsBox.valueLabel.text = "\(t.teamIds.count)"
        playedBox.valueLabel.text = "\(t.matchesPlayed)"
        remainingBox.valueLabel.text = "\(t.matchesRemaining)"
        configureStatusPill(for: t.status)
        showTab(tabs.selectedIndex, for: t)
    }

    private func configureStatusPill(for status: Tournament.Status) {
        let text: String
        let fg: UIColor
        let bg: UIColor
        switch status {
        case .live:
            text = "● Live"; fg = .black; bg = Theme.Color.accent
        case .scheduled:
            text = "Scheduled"
            fg = UIColor(hex: 0xFFBE5C)
            bg = UIColor(hex: 0xFFBE5C).withAlphaComponent(0.15)
        case .completed:
            text = "Finished"; fg = Theme.Color.textSecondary; bg = Theme.Color.surfaceElevated
        }
        statusPill.text = text
        statusPill.textColor = fg
        statusPill.backgroundColor = bg
    }

    private func showTab(_ index: Int, for tournament: Tournament) {
        tabContainer.subviews.forEach { $0.removeFromSuperview() }
        let v: UIView
        switch index {
        case 0:
            if tournament.format == .knockout {
                v = KnockoutBracketView(tournament: tournament,
                                        onTapMatch: { [weak self] id in self?.presentScoreEntry(matchId: id) })
            } else {
                v = StandingsTableView(rows: DataStore.shared.standings(for: tournament))
            }
        case 1:
            v = MatchesListView(tournament: tournament,
                                onTapMatch: { [weak self] matchId in
                                    self?.presentScoreEntry(matchId: matchId)
                                })
        default:
            v = ScorersListView(entries: DataStore.shared.scorersByTeam(for: tournament))
        }
        tabContainer.addSubview(v)
        v.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func presentScoreEntry(matchId: UUID) {
        let vc = ScoreEntryViewController(tournamentId: tournamentId, matchId: matchId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class StandingsTableView: UIView {
    init(rows: [StandingRow]) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        clipsToBounds = true

        if rows.isEmpty {
            let l = UILabel()
            l.text = "No teams yet"
            l.font = Theme.Font.regular(13)
            l.textColor = Theme.Color.textSecondary
            l.textAlignment = .center
            addSubview(l)
            l.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(24)
            }
            return
        }

        let headerStack = makeHeaderRow()
        addSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }

        var last: UIView = headerStack
        for (i, row) in rows.enumerated() {
            let line = UIView(); line.backgroundColor = Theme.Color.divider
            addSubview(line)
            line.snp.makeConstraints { make in
                make.top.equalTo(last.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
            }
            let rowView = makeRow(row, isFirst: i == 0, isLast: i == rows.count - 1)
            addSubview(rowView)
            rowView.snp.makeConstraints { make in
                make.top.equalTo(line.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(36)
            }
            last = rowView
        }
        last.snp.makeConstraints { $0.bottom.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeHeaderRow() -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surfaceElevated
        let labels = ["P", "Team", "P", "W", "D", "L", "GF", "GA", "GD", "Pts"]
        let widths: [CGFloat] = [22, 0, 22, 22, 22, 22, 22, 22, 22, 28]
        addStackedRow(in: v, labels: labels, widths: widths, font: Theme.Font.semibold(11), color: Theme.Color.textSecondary)
        return v
    }

    private func makeRow(_ row: StandingRow, isFirst: Bool, isLast: Bool) -> UIView {
        let v = UIView()
        let pillBar = UIView()
        pillBar.backgroundColor = isFirst ? Theme.Color.accent : (isLast ? Theme.Color.loss : .clear)
        v.addSubview(pillBar)
        pillBar.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(2.5)
        }
        let labels = [
            "\(row.position)", row.teamName,
            "\(row.played)", "\(row.won)", "\(row.drawn)", "\(row.lost)",
            "\(row.goalsFor)", "\(row.goalsAgainst)",
            "\(row.goalDiff > 0 ? "+\(row.goalDiff)" : "\(row.goalDiff)")",
            "\(row.points)"
        ]
        let widths: [CGFloat] = [22, 0, 22, 22, 22, 22, 22, 22, 22, 28]
        let isAccent = isFirst
        addStackedRow(in: v, labels: labels, widths: widths,
                      font: Theme.Font.semibold(12),
                      color: isAccent ? Theme.Color.accent : .white,
                      pointsColor: isAccent ? Theme.Color.accent : .white)
        return v
    }

    private func addStackedRow(in container: UIView, labels: [String], widths: [CGFloat], font: UIFont, color: UIColor, pointsColor: UIColor? = nil) {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
        for (i, text) in labels.enumerated() {
            let l = UILabel()
            l.text = text
            l.font = font
            l.textColor = (i == labels.count - 1 && pointsColor != nil) ? pointsColor : color
            if i == 1 {
                l.setContentHuggingPriority(.defaultLow, for: .horizontal)
                stack.addArrangedSubview(l)
            } else {
                l.textAlignment = .center
                let wrap = UIView()
                wrap.addSubview(l)
                l.snp.makeConstraints { $0.center.equalToSuperview() }
                wrap.snp.makeConstraints { $0.width.equalTo(widths[i]) }
                stack.addArrangedSubview(wrap)
            }
        }
    }
}

final class MatchesListView: UIView {
    private let onTapMatch: (UUID) -> Void
    private let format: Tournament.Format

    init(tournament: Tournament, onTapMatch: @escaping (UUID) -> Void) {
        self.onTapMatch = onTapMatch
        self.format = tournament.format
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        if tournament.matches.isEmpty {
            let l = UILabel()
            l.text = "No matches scheduled"
            l.font = Theme.Font.regular(13)
            l.textColor = Theme.Color.textSecondary
            l.textAlignment = .center
            stack.addArrangedSubview(l)
            return
        }

        if tournament.format == .knockout {
            buildKnockoutView(stack: stack, matches: tournament.matches)
        } else {
            buildLeagueView(stack: stack, matches: tournament.matches)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLeagueView(stack: UIStackView, matches: [Match]) {
        let played = matches.filter { $0.isPlayed }
        let upcoming = matches.filter { !$0.isPlayed }
        if !played.isEmpty {
            let h = SectionLabelView("Results", color: Theme.Color.textSecondary)
            stack.addArrangedSubview(h)
            stack.setCustomSpacing(8, after: h)
            for m in played { stack.addArrangedSubview(makeResultRow(m)) }
            stack.setCustomSpacing(20, after: stack.arrangedSubviews.last!)
        }
        if !upcoming.isEmpty {
            let h = SectionLabelView("Upcoming — tap to enter score", color: Theme.Color.textSecondary)
            stack.addArrangedSubview(h)
            stack.setCustomSpacing(8, after: h)
            for m in upcoming { stack.addArrangedSubview(makeUpcomingRow(m)) }
        }
    }

    private func buildKnockoutView(stack: UIStackView, matches: [Match]) {
        let maxRound = matches.map { $0.round }.max() ?? 1
        let totalParticipants = Set(matches.flatMap { [$0.homeTeamId, $0.awayTeamId] }).count
        for round in 1...maxRound {
            let roundMatches = matches.filter { $0.round == round }
            guard !roundMatches.isEmpty else { continue }
            let label = roundTitle(round: round,
                                   maxRound: maxRound,
                                   matchesInRound: roundMatches.count,
                                   totalParticipants: totalParticipants)
            let h = SectionLabelView(label, color: Theme.Color.textSecondary)
            stack.addArrangedSubview(h)
            stack.setCustomSpacing(8, after: h)
            for m in roundMatches {
                let row = m.isPlayed ? makeResultRow(m) : makeUpcomingRow(m)
                stack.addArrangedSubview(row)
            }
            stack.setCustomSpacing(20, after: stack.arrangedSubviews.last!)
        }
    }

    private func roundTitle(round: Int, maxRound: Int, matchesInRound: Int, totalParticipants: Int) -> String {
        if matchesInRound == 1 { return "Final" }
        if matchesInRound == 2 { return "Semifinals" }
        if matchesInRound == 4 { return "Quarterfinals" }
        return "Round \(round)"
    }

    private func teamName(_ id: UUID) -> String { DataStore.shared.team(id: id)?.name ?? "—" }

    private func makeResultRow(_ m: Match) -> UIView {
        let v = UIControl()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let home = UILabel(); home.text = teamName(m.homeTeamId); home.font = Theme.Font.regular(13); home.textColor = Theme.Color.textPrimary; home.textAlignment = .right
        let score = UILabel()
        score.text = "\(m.homeScore ?? 0) - \(m.awayScore ?? 0)"
        score.font = Theme.Font.bold(14); score.textColor = Theme.Color.textPrimary; score.textAlignment = .center
        let away = UILabel(); away.text = teamName(m.awayTeamId); away.font = Theme.Font.regular(13); away.textColor = Theme.Color.textPrimary
        let edit = UIImageView(image: UIImage(systemName: "square.and.pencil"))
        edit.tintColor = Theme.Color.textSecondary
        edit.contentMode = .scaleAspectFit

        [home, score, away, edit].forEach { v.addSubview($0) }
        home.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(score.snp.leading).offset(-8)
        }
        score.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(46)
        }
        away.snp.makeConstraints { make in
            make.leading.equalTo(score.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(edit.snp.leading).offset(-8)
        }
        edit.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        let id = m.id
        v.addAction(UIAction { [weak self] _ in self?.onTapMatch(id) }, for: .touchUpInside)
        return v
    }

    private func makeUpcomingRow(_ m: Match) -> UIView {
        let v = UIControl()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let home = UILabel(); home.text = teamName(m.homeTeamId); home.font = Theme.Font.regular(13); home.textColor = Theme.Color.textPrimary; home.textAlignment = .right
        let badge = PillLabel(text: "TBD", textColor: Theme.Color.accent,
                              background: Theme.Color.accent.withAlphaComponent(0.15), fontSize: 11)
        let away = UILabel(); away.text = teamName(m.awayTeamId); away.font = Theme.Font.regular(13); away.textColor = Theme.Color.textPrimary
        let plus = UIImageView(image: UIImage(systemName: "plus"))
        plus.tintColor = Theme.Color.textSecondary
        plus.contentMode = .scaleAspectFit

        [home, badge, away, plus].forEach { v.addSubview($0) }
        home.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(badge.snp.leading).offset(-8)
        }
        badge.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        away.snp.makeConstraints { make in
            make.leading.equalTo(badge.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(plus.snp.leading).offset(-8)
        }
        plus.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
        let id = m.id
        v.addAction(UIAction { [weak self] _ in self?.onTapMatch(id) }, for: .touchUpInside)
        return v
    }
}

final class KnockoutBracketView: UIView {
    init(tournament: Tournament, onTapMatch: @escaping (UUID) -> Void) {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        let matches = tournament.matches
        if matches.isEmpty {
            let l = UILabel()
            l.text = "No bracket yet"
            l.font = Theme.Font.regular(13)
            l.textColor = Theme.Color.textSecondary
            l.textAlignment = .center
            stack.addArrangedSubview(l)
            return
        }
        let maxRound = matches.map { $0.round }.max() ?? 1
        for round in 1...maxRound {
            let roundMatches = matches.filter { $0.round == round }
            guard !roundMatches.isEmpty else { continue }
            let title = roundMatches.count == 1 ? "Final"
                       : roundMatches.count == 2 ? "Semifinals"
                       : roundMatches.count == 4 ? "Quarterfinals"
                       : "Round \(round)"
            let header = SectionLabelView(title, color: Theme.Color.textSecondary)
            stack.addArrangedSubview(header)
            stack.setCustomSpacing(8, after: header)
            for m in roundMatches {
                stack.addArrangedSubview(makeBracketCell(m, onTap: onTapMatch))
            }
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeBracketCell(_ m: Match, onTap: @escaping (UUID) -> Void) -> UIView {
        let card = UIControl()
        card.backgroundColor = Theme.Color.surface
        card.layer.cornerRadius = 12
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)) }
        stack.addArrangedSubview(makeRow(name: DataStore.shared.team(id: m.homeTeamId)?.name ?? "—",
                                          score: m.homeScore,
                                          isWinner: m.winnerId == m.homeTeamId))
        stack.addArrangedSubview(makeRow(name: DataStore.shared.team(id: m.awayTeamId)?.name ?? "—",
                                          score: m.awayScore,
                                          isWinner: m.winnerId == m.awayTeamId))
        let id = m.id
        card.addAction(UIAction { _ in onTap(id) }, for: .touchUpInside)
        return card
    }

    private func makeRow(name: String, score: Int?, isWinner: Bool) -> UIView {
        let row = UIView()
        let n = UILabel()
        n.text = name
        n.font = isWinner ? Theme.Font.bold(14) : Theme.Font.regular(14)
        n.textColor = isWinner ? Theme.Color.accent : Theme.Color.textPrimary
        let s = UILabel()
        s.text = score.map { "\($0)" } ?? "–"
        s.font = isWinner ? Theme.Font.bold(15) : Theme.Font.semibold(14)
        s.textColor = isWinner ? Theme.Color.accent : Theme.Color.textPrimary
        row.addSubview(n)
        row.addSubview(s)
        n.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        s.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        row.snp.makeConstraints { $0.height.equalTo(32) }
        return row
    }
}

final class ScorersListView: UIView {
    init(entries: [(teamId: UUID, teamName: String, goals: Int)]) {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        let header = SectionLabelView("Goals scored by team", color: Theme.Color.textSecondary)
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        if entries.isEmpty {
            let l = UILabel()
            l.text = "No goals scored yet"
            l.font = Theme.Font.regular(13)
            l.textColor = Theme.Color.textSecondary
            l.textAlignment = .center
            stack.addArrangedSubview(l)
            return
        }

        for (i, e) in entries.enumerated() {
            stack.addArrangedSubview(makeRow(team: e.teamName, goals: e.goals, rank: i + 1))
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeRow(team: String, goals: Int, rank: Int) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let trophy = UIImageView(image: UIImage(systemName: rank == 1 ? "trophy.fill" : "trophy"))
        trophy.tintColor = rank == 1 ? Theme.Color.draw : Theme.Color.textTertiary
        trophy.contentMode = .scaleAspectFit

        let name = UILabel(); name.text = team; name.font = Theme.Font.semibold(14); name.textColor = Theme.Color.textPrimary
        let goalsVal = UILabel(); goalsVal.text = "\(goals)"
        goalsVal.font = Theme.Font.bold(18)
        goalsVal.textColor = Theme.Color.accent
        let goalsCaption = UILabel(); goalsCaption.text = "goals"
        goalsCaption.font = Theme.Font.regular(12); goalsCaption.textColor = Theme.Color.textSecondary

        [trophy, name, goalsVal, goalsCaption].forEach { v.addSubview($0) }
        trophy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        name.snp.makeConstraints { make in
            make.leading.equalTo(trophy.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        goalsCaption.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        goalsVal.snp.makeConstraints { make in
            make.trailing.equalTo(goalsCaption.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }
        return v
    }
}
