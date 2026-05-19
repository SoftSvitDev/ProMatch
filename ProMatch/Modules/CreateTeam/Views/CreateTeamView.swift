import UIKit
import SnapKit

final class CreateTeamView: UIView {
    let navBar = NavBarView(title: "Create Team")

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.backgroundColor = .clear
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()

    let contentView = UIView()

    let logoView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.pillRed
        v.layer.cornerRadius = 20
        v.clipsToBounds = false
        return v
    }()

    let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "FC"
        l.textColor = .white
        l.font = Theme.Font.bold(28)
        l.textAlignment = .center
        return l
    }()

    let cameraBadge: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.accent
        v.layer.cornerRadius = 12
        let iv = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)))
        iv.tintColor = .black
        v.addSubview(iv)
        iv.snp.makeConstraints { $0.center.equalToSuperview() }
        return v
    }()

    let uploadHint: UILabel = {
        let l = UILabel()
        l.text = "Tap to upload photo"
        l.font = Theme.Font.regular(13)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        return l
    }()

    let nameField = LabeledTextField(title: "Team Name", placeholder: "e.g. FC Predators")

    let kitColorsLabel = SectionHeaderLabel("Kit Colors")
    let primarySwatchRow = ColorSwatchRow(title: "Primary")
    let secondarySwatchRow = ColorSwatchRow(title: "Secondary")

    let cityField = LabeledTextField(title: "City", placeholder: "e.g. Manchester")
    let foundedField = LabeledTextField(title: "Founded", placeholder: "e.g. 2018", keyboard: .numberPad)

    let notesLabel = SectionHeaderLabel("Notes")
    let notesView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = Theme.Color.inputBackground
        tv.layer.cornerRadius = Theme.Metric.inputRadius
        tv.font = Theme.Font.regular(15)
        tv.textColor = .white
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()

    let notesPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Team notes, tactics, style of play..."
        l.font = Theme.Font.regular(15)
        l.textColor = Theme.Color.textTertiary
        return l
    }()

    let saveButton = PrimaryButton(title: "Save Team", style: .disabled)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Color.background
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(navBar)
        addSubview(scrollView)
        addSubview(saveButton)
        scrollView.addSubview(contentView)
        [logoView, uploadHint, nameField, kitColorsLabel,
         primarySwatchRow, secondarySwatchRow, cityField, foundedField,
         notesLabel, notesView].forEach { contentView.addSubview($0) }
        logoView.addSubview(logoLabel)
        logoView.addSubview(cameraBadge)
        notesView.addSubview(notesPlaceholder)
    }

    private func setupConstraints() {
        navBar.snp.makeConstraints { make in
            make.top.equalTo(safeTop)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(72)
        }
        logoLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        cameraBadge.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(4)
        }
        uploadHint.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        nameField.snp.makeConstraints { make in
            make.top.equalTo(uploadHint.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        kitColorsLabel.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        primarySwatchRow.snp.makeConstraints { make in
            make.top.equalTo(kitColorsLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        secondarySwatchRow.snp.makeConstraints { make in
            make.top.equalTo(primarySwatchRow.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        cityField.snp.makeConstraints { make in
            make.top.equalTo(secondarySwatchRow.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        foundedField.snp.makeConstraints { make in
            make.top.equalTo(cityField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        notesLabel.snp.makeConstraints { make in
            make.top.equalTo(foundedField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        notesView.snp.makeConstraints { make in
            make.top.equalTo(notesLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(90)
            make.bottom.equalToSuperview().offset(-16)
        }
        notesPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.leading.equalToSuperview().offset(16)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeBottom).offset(-16)
            make.height.equalTo(Theme.Metric.buttonHeight)
        }
    }
}

final class ColorSwatchRow: UIView {
    private let titleLabel = UILabel()
    private let gridStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.alignment = .fill
        return s
    }()
    private var swatches: [SwatchDot] = []
    private(set) var selectedIndex: Int = 0
    var onSelect: ((UIColor) -> Void)?

    private let colors: [UIColor] = [
        UIColor(hex: 0xEF4444), UIColor(hex: 0xF97316), UIColor(hex: 0xF59E0B),
        UIColor(hex: 0xFACC15), UIColor(hex: 0x84CC16), UIColor(hex: 0x22C55E),
        UIColor(hex: 0x10B981), UIColor(hex: 0x06B6D4),
        UIColor(hex: 0x3B82F6), UIColor(hex: 0x6366F1), UIColor(hex: 0x8B5CF6),
        UIColor(hex: 0xA855F7), UIColor(hex: 0xEC4899), UIColor(hex: 0xFFFFFF),
        UIColor(hex: 0x9CA3AF), UIColor(hex: 0x6B7280),
    ]

    init(title: String, defaultIndex: Int = 0) {
        super.init(frame: .zero)
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [.foregroundColor: Theme.Color.textSecondary,
                         .font: Theme.Font.regular(12)]
        )
        addSubview(titleLabel)
        addSubview(gridStack)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        gridStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        addRow(colors: Array(colors.prefix(8)), startIndex: 0)
        addRow(colors: Array(colors.suffix(8)), startIndex: 8)
        select(defaultIndex)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func addRow(colors: [UIColor], startIndex: Int) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .equalSpacing
        for (i, color) in colors.enumerated() {
            let dot = SwatchDot(color: color)
            dot.tag = startIndex + i
            dot.addTarget(self, action: #selector(swatchTapped(_:)), for: .touchUpInside)
            swatches.append(dot)
            row.addArrangedSubview(dot)
        }
        gridStack.addArrangedSubview(row)
        row.snp.makeConstraints { make in
            make.width.equalTo(gridStack.snp.width)
        }
    }

    @objc private func swatchTapped(_ sender: SwatchDot) {
        select(sender.tag)
        onSelect?(colors[sender.tag])
    }

    func select(_ index: Int) {
        selectedIndex = index
        for (i, dot) in swatches.enumerated() { dot.isOn = (i == index) }
    }

    var color: UIColor { colors[selectedIndex] }
}

final class SwatchDot: UIControl {
    private let circle = UIView()
    private let ring = CAShapeLayer()
    private let color: UIColor

    var isOn: Bool = false {
        didSet { ring.opacity = isOn ? 1 : 0 }
    }

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        circle.backgroundColor = color
        circle.layer.cornerRadius = 12
        circle.isUserInteractionEnabled = false
        addSubview(circle)
        circle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = UIColor.white.cgColor
        ring.lineWidth = 2
        ring.opacity = 0
        layer.addSublayer(ring)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 1
        let rect = bounds.insetBy(dx: inset, dy: inset)
        ring.path = UIBezierPath(ovalIn: rect).cgPath
    }
}
