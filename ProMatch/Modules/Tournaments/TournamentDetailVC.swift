import UIKit
import SnapKit

final class TournamentDetailViewController: UIViewController {
    private let tournament: Tournament
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let navBar: NavBarView
    private let livePill = PillLabel(text: "● Live", textColor: .black, background: Theme.Color.accent, fontSize: 11)
    private let subtitle: UILabel
    private let teamsBox = StatBox(color: Theme.Color.accent, title: "Teams")
    private let playedBox = StatBox(color: Theme.Color.accent, title: "Played")
    private let remainingBox = StatBox(color: Theme.Color.accent, title: "Remaining")
    private let tabs = SegmentedTabsView(items: ["Standings", "Matches", "Scorers"])
    private let tabContainer = UIView()

    init(tournament: Tournament) {
        self.tournament = tournament
        self.navBar = NavBarView(title: tournament.name)
        self.subtitle = UILabel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        subtitle.font = Theme.Font.regular(13)
        subtitle.textColor = Theme.Color.textSecondary
        subtitle.text = tournament.format.rawValue

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        [navBar, livePill, subtitle, teamsBox, playedBox, remainingBox, tabs, tabContainer].forEach {
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
        livePill.snp.makeConstraints { make in
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

        teamsBox.valueLabel.text = "\(tournament.teamCount)"
        playedBox.valueLabel.text = "\(tournament.matchesPlayed)"
        remainingBox.valueLabel.text = "\(tournament.remaining)"

        navBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        tabs.onChange = { [weak self] idx in self?.showTab(idx) }
        showTab(0)
    }

    @objc private func back() { navigationController?.popViewController(animated: true) }

    private func showTab(_ index: Int) {
        tabContainer.subviews.forEach { $0.removeFromSuperview() }
        let view: UIView
        switch index {
        case 0: view = StandingsTableView(rows: SampleData.standings)
        case 1: view = MatchesListView(results: SampleData.results, upcoming: SampleData.upcoming)
        default: view = ScorersListView(entries: SampleData.scorers)
        }
        tabContainer.addSubview(view)
        view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

final class StandingsTableView: UIView {
    init(rows: [StandingRow]) {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.surface
        layer.cornerRadius = Theme.Metric.cardRadius
        clipsToBounds = true

        let headerStack = makeHeaderRow()
        addSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }

        var last: UIView = headerStack
        for row in rows {
            let line = UIView(); line.backgroundColor = Theme.Color.divider
            addSubview(line)
            line.snp.makeConstraints { make in
                make.top.equalTo(last.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
            }
            let rowView = makeRow(row)
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

    private func makeRow(_ row: StandingRow) -> UIView {
        let v = UIView()
        let pillBar = UIView()
        pillBar.backgroundColor = row.position == 1 ? Theme.Color.accent : (row.position == 4 ? Theme.Color.loss : .clear)
        v.addSubview(pillBar)
        pillBar.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(2.5)
        }
        let labels = [
            "\(row.position)", row.team,
            "\(row.played)", "\(row.won)", "\(row.drawn)", "\(row.lost)",
            "\(row.goalsFor)", "\(row.goalsAgainst)", "\(row.goalDiff > 0 ? "+\(row.goalDiff)" : "\(row.goalDiff)")",
            "\(row.points)"
        ]
        let widths: [CGFloat] = [22, 0, 22, 22, 22, 22, 22, 22, 22, 28]
        let isAccent = row.position == 1
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
        stack.spacing = 0
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
    init(results: [MatchResult], upcoming: [UpcomingMatch]) {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        let resultsHeader = SectionLabelView("Results", color: Theme.Color.textSecondary)
        stack.addArrangedSubview(resultsHeader)
        stack.setCustomSpacing(8, after: resultsHeader)

        for r in results {
            let row = makeResultRow(r)
            stack.addArrangedSubview(row)
        }
        stack.setCustomSpacing(20, after: stack.arrangedSubviews.last!)

        let upcomingHeader = SectionLabelView("Upcoming — tap to enter score", color: Theme.Color.textSecondary)
        stack.addArrangedSubview(upcomingHeader)
        stack.setCustomSpacing(8, after: upcomingHeader)

        for u in upcoming {
            let row = makeUpcomingRow(u)
            stack.addArrangedSubview(row)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeResultRow(_ r: MatchResult) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let home = UILabel(); home.text = r.home; home.font = Theme.Font.regular(13); home.textColor = .white; home.textAlignment = .right
        let score = UILabel(); score.text = "\(r.homeScore) - \(r.awayScore)"; score.font = Theme.Font.bold(14); score.textColor = .white; score.textAlignment = .center
        let away = UILabel(); away.text = r.away; away.font = Theme.Font.regular(13); away.textColor = .white
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
        return v
    }

    private func makeUpcomingRow(_ u: UpcomingMatch) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let home = UILabel(); home.text = u.home; home.font = Theme.Font.regular(13); home.textColor = .white; home.textAlignment = .right
        let time = PillLabel(text: u.time, textColor: Theme.Color.accent, background: Theme.Color.accent.withAlphaComponent(0.15), fontSize: 11)
        let away = UILabel(); away.text = u.away; away.font = Theme.Font.regular(13); away.textColor = .white
        let plus = UIImageView(image: UIImage(systemName: "plus"))
        plus.tintColor = Theme.Color.textSecondary
        plus.contentMode = .scaleAspectFit

        [home, time, away, plus].forEach { v.addSubview($0) }
        home.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(time.snp.leading).offset(-8)
        }
        time.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        away.snp.makeConstraints { make in
            make.leading.equalTo(time.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(plus.snp.leading).offset(-8)
        }
        plus.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
        return v
    }
}

final class ScorersListView: UIView {
    init(entries: [ScorerEntry]) {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        let header = SectionLabelView("Goals scored by team", color: Theme.Color.textSecondary)
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        for (i, e) in entries.enumerated() {
            let row = makeRow(e, rank: i + 1)
            stack.addArrangedSubview(row)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeRow(_ e: ScorerEntry, rank: Int) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 12
        v.snp.makeConstraints { $0.height.equalTo(48) }

        let trophy = UIImageView(image: UIImage(systemName: rank == 1 ? "trophy.fill" : "trophy"))
        trophy.tintColor = rank == 1 ? Theme.Color.draw : Theme.Color.textTertiary
        trophy.contentMode = .scaleAspectFit

        let name = UILabel(); name.text = e.team; name.font = Theme.Font.semibold(14); name.textColor = .white
        let goalsVal = UILabel(); goalsVal.text = "\(e.goals)"
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
