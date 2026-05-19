import UIKit
import SnapKit

final class NewTournamentViewController: UIViewController {
    private var newTournamentView: NewTournamentView { view as! NewTournamentView }
    private var step = 1
    private let totalSteps = 4
    private var selectedTeamCount = 0

    override func loadView() { view = NewTournamentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        newTournamentView.navBar.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        newTournamentView.continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        showStep()
    }

    private func showStep() {
        newTournamentView.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        newTournamentView.configureProgress(step: step, totalSteps: totalSteps)
        switch step {
        case 1: buildStep1()
        case 2: buildStep2()
        case 3: buildStep3()
        case 4: buildStep4()
        default: break
        }
    }

    private func buildStep1() {
        let stack = newTournamentView.contentStack

        let nameField = LabeledTextField(title: "Tournament Name", placeholder: "e.g. City Cup 2026")
        stack.addArrangedSubview(nameField)
        stack.setCustomSpacing(8, after: nameField)

        let formatHeader = SectionHeaderLabel("Format")
        stack.addArrangedSubview(formatHeader)
        stack.setCustomSpacing(8, after: formatHeader)

        stack.addArrangedSubview(FormatOptionRow(symbol: "globe", title: "Round-Robin", subtitle: "Every team plays each other once"))
        stack.addArrangedSubview(FormatOptionRow(symbol: "flag", title: "Knockout", subtitle: "Lose once and you're out"))
        stack.addArrangedSubview(FormatOptionRow(symbol: "rectangle.grid.2x2", title: "Groups + Playoffs", subtitle: "Group stage then knockouts"))

        let datesContainer = UIView()
        let startCol = UIView()
        let endCol = UIView()
        let startLabel = SectionHeaderLabel("Start Date")
        let endLabel = SectionHeaderLabel("End Date")
        let startField = UIView(); startField.backgroundColor = Theme.Color.inputBackground; startField.layer.cornerRadius = Theme.Metric.inputRadius
        let endField = UIView(); endField.backgroundColor = Theme.Color.inputBackground; endField.layer.cornerRadius = Theme.Metric.inputRadius
        startCol.addSubview(startLabel); startCol.addSubview(startField)
        endCol.addSubview(endLabel); endCol.addSubview(endField)
        startLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        startField.snp.makeConstraints { make in
            make.top.equalTo(startLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        endLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        endField.snp.makeConstraints { make in
            make.top.equalTo(endLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        datesContainer.addSubview(startCol)
        datesContainer.addSubview(endCol)
        startCol.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(endCol)
        }
        endCol.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(startCol.snp.trailing).offset(12)
        }
        stack.setCustomSpacing(16, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(datesContainer)

        newTournamentView.continueButton.style = .disabled
    }

    private func buildStep2() {
        let stack = newTournamentView.contentStack
        let header = SectionHeaderLabel("Select Teams (\(selectedTeamCount) selected)")
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        for team in SampleData.teams {
            let row = TeamSelectRow(team: team)
            row.addTarget(self, action: #selector(teamRowTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        newTournamentView.continueButton.style = selectedTeamCount > 0 ? .primary : .disabled
    }

    @objc private func teamRowTapped(_ sender: TeamSelectRow) {
        if let header = newTournamentView.contentStack.arrangedSubviews.first as? UILabel {
            let count = newTournamentView.contentStack.arrangedSubviews.compactMap { $0 as? TeamSelectRow }.filter { $0.isOn }.count
            selectedTeamCount = count
            header.attributedText = NSAttributedString(
                string: "Select Teams (\(count) selected)".uppercased(),
                attributes: [.foregroundColor: Theme.Color.textSecondary, .kern: 0.5, .font: Theme.Font.semibold(11)]
            )
        }
        newTournamentView.continueButton.style = selectedTeamCount > 0 ? .primary : .disabled
    }

    private func buildStep3() {
        let stack = newTournamentView.contentStack
        let h1 = SectionHeaderLabel("Match Rules")
        stack.addArrangedSubview(h1)
        stack.setCustomSpacing(8, after: h1)
        stack.addArrangedSubview(RuleStepperRow(title: "Match duration (min)", initial: 90))

        let h2 = SectionHeaderLabel("Points System")
        stack.addArrangedSubview(h2)
        stack.setCustomSpacing(8, after: h2)
        stack.addArrangedSubview(RuleStepperRow(title: "Points for Win", initial: 3))
        stack.addArrangedSubview(RuleStepperRow(title: "Points for Draw", initial: 1))
        stack.addArrangedSubview(RuleStepperRow(title: "Points for Loss", initial: 0))

        let h3 = SectionHeaderLabel("Tiebreaker")
        stack.addArrangedSubview(h3)
        stack.setCustomSpacing(8, after: h3)

        let options = ["Goal Difference", "Head-to-Head", "Goals Scored", "Coin Toss"]
        for (i, title) in options.enumerated() {
            let row = TiebreakerRow(title: title)
            if i == 0 { row.isSelected2 = true }
            row.addTarget(self, action: #selector(tiebreakerTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        newTournamentView.continueButton.style = .primary
    }

    @objc private func tiebreakerTapped(_ sender: TiebreakerRow) {
        for v in newTournamentView.contentStack.arrangedSubviews {
            if let row = v as? TiebreakerRow {
                row.isSelected2 = (row === sender)
            }
        }
    }

    private func buildStep4() {
        let stack = newTournamentView.contentStack

        let header = SectionHeaderLabel("Review & Confirm")
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        let summary = ReviewSummaryView(rows: [
            ("Tournament", ""),
            ("Format", "Round-Robin"),
            ("Teams", "\(max(selectedTeamCount, 2)) selected"),
            ("Match Duration", "90 min"),
            ("Points (W/D/L)", "3 / 1 / 0"),
            ("Tiebreaker", "Goal Difference"),
            ("Dates", "Not set"),
        ])
        stack.addArrangedSubview(summary)

        let teamsHeader = SectionHeaderLabel("Participating Teams")
        stack.addArrangedSubview(teamsHeader)
        stack.setCustomSpacing(8, after: teamsHeader)

        let chipsRow = UIStackView()
        chipsRow.axis = .horizontal
        chipsRow.spacing = 8

        for team in SampleData.teams.prefix(2) {
            let chip = UIView()
            chip.backgroundColor = Theme.Color.surface
            chip.layer.cornerRadius = 12
            let dot = UIView()
            dot.backgroundColor = team.color
            dot.layer.cornerRadius = 4
            let l = UILabel()
            l.text = team.name
            l.textColor = .white
            l.font = Theme.Font.semibold(12)
            chip.addSubview(dot)
            chip.addSubview(l)
            dot.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.centerY.equalToSuperview()
                make.size.equalTo(8)
            }
            l.snp.makeConstraints { make in
                make.leading.equalTo(dot.snp.trailing).offset(6)
                make.top.equalToSuperview().offset(6)
                make.bottom.equalToSuperview().offset(-6)
                make.trailing.equalToSuperview().offset(-10)
            }
            chipsRow.addArrangedSubview(chip)
        }
        chipsRow.addArrangedSubview(UIView())
        stack.addArrangedSubview(chipsRow)

        newTournamentView.continueButton.setTitle("Create Tournament", for: .normal)
        newTournamentView.continueButton.style = .primary
    }

    @objc private func continueTapped() {
        if step < totalSteps {
            step += 1
            showStep()
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func back() {
        if step > 1 {
            step -= 1
            showStep()
        } else {
            dismiss(animated: true)
        }
    }
}
