import UIKit
import SnapKit

final class AddPlayerView: UIView {
    let navBar = NavBarView(title: "Add Player")

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()
    let contentView = UIView()

    let firstNameField = LabeledTextField(title: "First Name", placeholder: "Marcus")
    let lastNameField = LabeledTextField(title: "Last Name", placeholder: "Johnson")
    let nicknameField = LabeledTextField(title: "Nickname (optional)", placeholder: "e.g. Magic")

    let jerseyLabel = SectionHeaderLabel("Jersey Number")
    let jerseyStepper = NumberStepper(initial: 1)

    let positionLabel = SectionHeaderLabel("Position")
    let positionGrid = PositionGrid()

    let footLabel = SectionHeaderLabel("Preferred Foot")
    let footSegment = SegmentedTabsView(items: ["Left", "Right", "Both"])

    let birthLabel = SectionHeaderLabel("Birth Date")
    let birthField: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.inputBackground
        v.layer.cornerRadius = Theme.Metric.inputRadius
        return v
    }()

    let heightField = LabeledTextField(title: "Height (cm)", placeholder: "182", keyboard: .numberPad)
    let weightField = LabeledTextField(title: "Weight (kg)", placeholder: "78", keyboard: .numberPad)

    let addButton = PrimaryButton(title: "Add Player", style: .disabled)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
        footSegment.select(1)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(navBar)
        addSubview(scrollView)
        addSubview(addButton)
        scrollView.addSubview(contentView)
        [firstNameField, lastNameField, nicknameField,
         jerseyLabel, jerseyStepper, positionLabel, positionGrid,
         footLabel, footSegment, birthLabel, birthField,
         heightField, weightField].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        navBar.snp.makeConstraints { make in
            make.top.equalTo(safeTop)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-12)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        firstNameField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(lastNameField)
        }
        lastNameField.snp.makeConstraints { make in
            make.top.equalTo(firstNameField)
            make.leading.equalTo(firstNameField.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-24)
        }
        nicknameField.snp.makeConstraints { make in
            make.top.equalTo(firstNameField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        jerseyLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        jerseyStepper.snp.makeConstraints { make in
            make.top.equalTo(jerseyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(jerseyStepper.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        positionGrid.snp.makeConstraints { make in
            make.top.equalTo(positionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        footLabel.snp.makeConstraints { make in
            make.top.equalTo(positionGrid.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        footSegment.snp.makeConstraints { make in
            make.top.equalTo(footLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
        birthLabel.snp.makeConstraints { make in
            make.top.equalTo(footSegment.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        birthField.snp.makeConstraints { make in
            make.top.equalTo(birthLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        heightField.snp.makeConstraints { make in
            make.top.equalTo(birthField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(weightField)
        }
        weightField.snp.makeConstraints { make in
            make.top.equalTo(heightField)
            make.leading.equalTo(heightField.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-16)
        }
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeBottom).offset(-16)
            make.height.equalTo(Theme.Metric.buttonHeight)
        }
    }
}

final class NumberStepper: UIView {
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)
    let valueLabel = UILabel()
    private(set) var value: Int = 1 { didSet { update() } }

    init(initial: Int) {
        super.init(frame: .zero)
        value = initial
        backgroundColor = Theme.Color.inputBackground
        layer.cornerRadius = Theme.Metric.inputRadius
        clipsToBounds = true

        minusButton.setImage(UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .normal)
        plusButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .normal)
        minusButton.tintColor = .white
        plusButton.tintColor = .white
        valueLabel.textColor = Theme.Color.accent
        valueLabel.font = Theme.Font.bold(16)
        valueLabel.textAlignment = .center

        addSubview(minusButton)
        addSubview(plusButton)
        addSubview(valueLabel)

        minusButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(56)
        }
        plusButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(56)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(minusButton.snp.trailing)
            make.trailing.equalTo(plusButton.snp.leading)
            make.top.bottom.equalToSuperview()
        }
        minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        update()
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func minus() { if value > 1 { value -= 1 } }
    @objc private func plus() { if value < 99 { value += 1 } }
    private func update() { valueLabel.text = "\(value)" }
}

final class PositionGrid: UIView {
    private let row1Stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fillEqually
        return s
    }()
    private let row2Stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        return s
    }()
    private var selected: Position?

    init() {
        super.init(frame: .zero)
        let row1: [Position] = [.GK, .LB, .CB, .RB, .LM, .CM]
        let row2: [Position] = [.RM, .LW, .ST, .RW]

        for p in row1 { row1Stack.addArrangedSubview(makeChip(p)) }
        for p in row2 { row2Stack.addArrangedSubview(makeChip(p)) }
        let spacer = UIView(); spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row2Stack.addArrangedSubview(spacer)

        addSubview(row1Stack)
        addSubview(row2Stack)
        row1Stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(32)
        }
        row2Stack.snp.makeConstraints { make in
            make.top.equalTo(row1Stack.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(32)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeChip(_ p: Position) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.Color.surface
        v.layer.cornerRadius = 8
        let l = UILabel()
        l.text = p.rawValue
        l.font = Theme.Font.bold(12)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        v.addSubview(l)
        l.snp.makeConstraints { $0.center.equalToSuperview() }
        v.snp.makeConstraints { $0.width.equalTo(48) }
        return v
    }
}
