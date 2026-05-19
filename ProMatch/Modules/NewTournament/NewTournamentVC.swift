import UIKit
import SnapKit

final class NewTournamentViewController: UIViewController {
    private var newTournamentView: NewTournamentView { view as! NewTournamentView }
    private var step = 1
    private let totalSteps = 4

    // collected state
    private var tournamentName: String = ""
    private var format: Tournament.Format = .roundRobin
    private var startDate: Date?
    private var endDate: Date?
    private var selectedTeamIds: Set<UUID> = []
    private var matchDuration: Int = 90
    private var pointsWin: Int = 3
    private var pointsDraw: Int = 1
    private var pointsLoss: Int = 0
    private var tiebreaker: Tournament.Tiebreaker = .goalDifference

    // step-specific control refs
    private weak var nameField: LabeledTextField?
    private weak var teamsHeader: SectionHeaderLabel?
    private weak var startDateLabel: UILabel?
    private weak var endDateLabel: UILabel?

    override func loadView() { view = NewTournamentView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardAvoidance()
        enableKeyboardDismissal()
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
        // Newly built text fields need Return-key dismissal too.
        wireReturnDismissOnAllTextFields()
    }

    // MARK: - Step 1: Name + Format + Dates

    private func buildStep1() {
        let stack = newTournamentView.contentStack

        let nf = LabeledTextField(title: "Tournament Name", placeholder: "e.g. City Cup 2026")
        nf.textField.text = tournamentName
        nf.textField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
        nameField = nf
        stack.addArrangedSubview(nf)
        stack.setCustomSpacing(8, after: nf)

        let formatHeader = SectionHeaderLabel("Format")
        stack.addArrangedSubview(formatHeader)
        stack.setCustomSpacing(8, after: formatHeader)

        let opt1 = FormatOptionRow(symbol: "globe", title: "Round-Robin", subtitle: "Every team plays each other once")
        opt1.format = .roundRobin
        opt1.addTarget(self, action: #selector(formatTapped(_:)), for: .touchUpInside)
        opt1.isOn = format == .roundRobin
        stack.addArrangedSubview(opt1)

        let opt2 = FormatOptionRow(symbol: "flag", title: "Knockout", subtitle: "Lose once and you're out")
        opt2.format = .knockout
        opt2.addTarget(self, action: #selector(formatTapped(_:)), for: .touchUpInside)
        opt2.isOn = format == .knockout
        stack.addArrangedSubview(opt2)

        let opt3 = FormatOptionRow(symbol: "rectangle.grid.2x2", title: "Groups + Playoffs", subtitle: "Group stage then knockouts")
        opt3.format = .groupsPlayoffs
        opt3.addTarget(self, action: #selector(formatTapped(_:)), for: .touchUpInside)
        opt3.isOn = format == .groupsPlayoffs
        stack.addArrangedSubview(opt3)

        let datesContainer = UIView()
        let startCol = UIView(); let endCol = UIView()
        let startHeader = SectionHeaderLabel("Start Date")
        let endHeader = SectionHeaderLabel("End Date")

        let startBtn = makeDateButton(label: { l in self.startDateLabel = l; self.refreshDateLabels() }, isStart: true)
        let endBtn = makeDateButton(label: { l in self.endDateLabel = l; self.refreshDateLabels() }, isStart: false)

        startCol.addSubview(startHeader); startCol.addSubview(startBtn)
        endCol.addSubview(endHeader); endCol.addSubview(endBtn)
        startHeader.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        startBtn.snp.makeConstraints { make in
            make.top.equalTo(startHeader.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        endHeader.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        endBtn.snp.makeConstraints { make in
            make.top.equalTo(endHeader.snp.bottom).offset(8)
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

        refreshDateLabels()
        updateContinueButton()
    }

    @objc private func nameChanged(_ tf: UITextField) {
        tournamentName = tf.text ?? ""
        updateContinueButton()
    }

    @objc private func formatTapped(_ sender: FormatOptionRow) {
        format = sender.format
        for v in newTournamentView.contentStack.arrangedSubviews {
            if let row = v as? FormatOptionRow { row.isOn = (row.format == format) }
        }
    }

    private func makeDateButton(label: (UILabel) -> Void, isStart: Bool) -> UIControl {
        let btn = UIControl()
        btn.backgroundColor = Theme.Color.inputBackground
        btn.layer.cornerRadius = Theme.Metric.inputRadius
        let l = UILabel()
        l.font = Theme.Font.regular(15)
        l.textColor = Theme.Color.textTertiary
        l.text = "Select"
        btn.addSubview(l)
        l.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        let calIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calIcon.tintColor = Theme.Color.textTertiary
        btn.addSubview(calIcon)
        calIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        btn.addAction(UIAction { [weak self] _ in
            self?.presentDatePicker(isStart: isStart)
        }, for: .touchUpInside)
        label(l)
        return btn
    }

    private func presentDatePicker(isStart: Bool) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.date = (isStart ? startDate : endDate) ?? Date()
        picker.overrideUserInterfaceStyle = .dark

        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 200),
        ])
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self else { return }
            if isStart { self.startDate = picker.date } else { self.endDate = picker.date }
            self.refreshDateLabels()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func refreshDateLabels() {
        let f = DateFormatter(); f.dateStyle = .medium
        if let d = startDate {
            startDateLabel?.text = f.string(from: d)
            startDateLabel?.textColor = Theme.Color.textPrimary
        }
        if let d = endDate {
            endDateLabel?.text = f.string(from: d)
            endDateLabel?.textColor = Theme.Color.textPrimary
        }
    }

    // MARK: - Step 2: Select Teams

    private func buildStep2() {
        let stack = newTournamentView.contentStack
        let header = SectionHeaderLabel("Select Teams (\(selectedTeamIds.count) selected)")
        teamsHeader = header
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        let teams = DataStore.shared.teams
        for team in teams {
            let row = TeamSelectRow(team: team)
            row.teamId = team.id
            row.isOn = selectedTeamIds.contains(team.id)
            row.addTarget(self, action: #selector(teamRowTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        updateContinueButton()
    }

    @objc private func teamRowTapped(_ sender: TeamSelectRow) {
        guard let id = sender.teamId else { return }
        if selectedTeamIds.contains(id) {
            selectedTeamIds.remove(id)
            sender.isOn = false
        } else {
            selectedTeamIds.insert(id)
            sender.isOn = true
        }
        teamsHeader?.attributedText = NSAttributedString(
            string: "Select Teams (\(selectedTeamIds.count) selected)".uppercased(),
            attributes: [.foregroundColor: Theme.Color.textSecondary,
                         .kern: 0.5, .font: Theme.Font.semibold(11)]
        )
        updateContinueButton()
    }

    // MARK: - Step 3: Rules

    private func buildStep3() {
        let stack = newTournamentView.contentStack

        let h1 = SectionHeaderLabel("Match Rules")
        stack.addArrangedSubview(h1)
        stack.setCustomSpacing(8, after: h1)
        let duration = RuleStepperRow(title: "Match duration (min)", initial: matchDuration)
        duration.stepper.onChange = { [weak self] v in self?.matchDuration = v }
        stack.addArrangedSubview(duration)

        let h2 = SectionHeaderLabel("Points System")
        stack.addArrangedSubview(h2)
        stack.setCustomSpacing(8, after: h2)

        let win = RuleStepperRow(title: "Points for Win", initial: pointsWin)
        win.stepper.onChange = { [weak self] v in self?.pointsWin = v }
        stack.addArrangedSubview(win)

        let draw = RuleStepperRow(title: "Points for Draw", initial: pointsDraw)
        draw.stepper.onChange = { [weak self] v in self?.pointsDraw = v }
        stack.addArrangedSubview(draw)

        let loss = RuleStepperRow(title: "Points for Loss", initial: pointsLoss)
        loss.stepper.onChange = { [weak self] v in self?.pointsLoss = v }
        stack.addArrangedSubview(loss)

        let h3 = SectionHeaderLabel("Tiebreaker")
        stack.addArrangedSubview(h3)
        stack.setCustomSpacing(8, after: h3)

        for option in Tournament.Tiebreaker.allCases {
            let row = TiebreakerRow(title: option.rawValue)
            row.tiebreaker = option
            row.isSelected2 = (option == tiebreaker)
            row.addTarget(self, action: #selector(tiebreakerTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        updateContinueButton()
    }

    @objc private func tiebreakerTapped(_ sender: TiebreakerRow) {
        guard let t = sender.tiebreaker else { return }
        tiebreaker = t
        for v in newTournamentView.contentStack.arrangedSubviews {
            if let row = v as? TiebreakerRow {
                row.isSelected2 = (row.tiebreaker == t)
            }
        }
    }

    // MARK: - Step 4: Review

    private func buildStep4() {
        let stack = newTournamentView.contentStack

        let header = SectionHeaderLabel("Review & Confirm")
        stack.addArrangedSubview(header)
        stack.setCustomSpacing(8, after: header)

        let df = DateFormatter(); df.dateStyle = .medium
        let dateText: String
        if let s = startDate, let e = endDate {
            dateText = "\(df.string(from: s)) – \(df.string(from: e))"
        } else if let s = startDate {
            dateText = df.string(from: s)
        } else {
            dateText = "Not set"
        }

        let summary = ReviewSummaryView(rows: [
            ("Tournament", tournamentName.isEmpty ? "—" : tournamentName),
            ("Format", format.rawValue),
            ("Teams", "\(selectedTeamIds.count) selected"),
            ("Match Duration", "\(matchDuration) min"),
            ("Points (W/D/L)", "\(pointsWin) / \(pointsDraw) / \(pointsLoss)"),
            ("Tiebreaker", tiebreaker.rawValue),
            ("Dates", dateText),
        ])
        stack.addArrangedSubview(summary)

        let teamsHeader = SectionHeaderLabel("Participating Teams")
        stack.addArrangedSubview(teamsHeader)
        stack.setCustomSpacing(8, after: teamsHeader)

        let chipsRow = UIStackView()
        chipsRow.axis = .horizontal
        chipsRow.spacing = 8

        for team in DataStore.shared.teams.filter({ selectedTeamIds.contains($0.id) }) {
            let chip = UIView()
            chip.backgroundColor = Theme.Color.surface
            chip.layer.cornerRadius = 12
            let dot = UIView()
            dot.backgroundColor = team.color
            dot.layer.cornerRadius = 4
            let l = UILabel()
            l.text = team.name
            l.textColor = Theme.Color.textPrimary
            l.font = Theme.Font.semibold(12)
            chip.addSubview(dot); chip.addSubview(l)
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

    // MARK: - Validation / navigation

    private func updateContinueButton() {
        var enabled = true
        switch step {
        case 1: enabled = !tournamentName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: enabled = selectedTeamIds.count >= 2
        case 3: enabled = true
        case 4: enabled = true
        default: break
        }
        newTournamentView.continueButton.setTitle(step == totalSteps ? "Create Tournament" : "Continue", for: .normal)
        newTournamentView.continueButton.style = enabled ? .primary : .disabled
    }

    @objc private func continueTapped() {
        if step < totalSteps {
            step += 1
            showStep()
        } else {
            createTournament()
        }
    }

    @objc private func back() {
        if step > 1 {
            step -= 1
            showStep()
        } else {
            close()
        }
    }

    private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func createTournament() {
        let teamIds = DataStore.shared.teams
            .filter { selectedTeamIds.contains($0.id) }
            .map { $0.id }
        let tournament = Tournament(
            name: tournamentName.trimmingCharacters(in: .whitespaces),
            format: format,
            startDate: startDate,
            endDate: endDate,
            teamIds: teamIds,
            matchDurationMin: matchDuration,
            pointsWin: pointsWin,
            pointsDraw: pointsDraw,
            pointsLoss: pointsLoss,
            tiebreaker: tiebreaker
        )
        DataStore.shared.addTournament(tournament)
        close()
    }
}
