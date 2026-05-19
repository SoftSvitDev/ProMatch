import UIKit

final class PrimaryButton: UIButton {
    enum Style {
        case primary
        case secondary
        case disabled
    }

    private let trailingIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .black
        iv.isHidden = true
        return iv
    }()

    var style: Style = .primary {
        didSet { applyStyle() }
    }

    init(title: String, icon: UIImage? = nil, style: Style = .primary) {
        super.init(frame: .zero)
        configuration = nil
        setTitle(title, for: .normal)
        titleLabel?.font = Theme.Font.bold(16)
        layer.cornerRadius = Theme.Metric.buttonRadius
        clipsToBounds = true
        self.style = style
        applyStyle()
        if let icon {
            trailingIcon.image = icon
            trailingIcon.isHidden = false
            addSubview(trailingIcon)
            trailingIcon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                trailingIcon.widthAnchor.constraint(equalToConstant: 18),
                trailingIcon.heightAnchor.constraint(equalToConstant: 18),
                trailingIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
            titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !trailingIcon.isHidden, let label = titleLabel else { return }
        let totalWidth = label.intrinsicContentSize.width + 8 + 18
        let labelX = (bounds.width - totalWidth) / 2
        label.frame.origin.x = labelX
        trailingIcon.frame.origin.x = labelX + label.intrinsicContentSize.width + 8
    }

    private func applyStyle() {
        switch style {
        case .primary:
            backgroundColor = Theme.Color.accent
            setTitleColor(.black, for: .normal)
            trailingIcon.tintColor = .black
            isUserInteractionEnabled = true
            alpha = 1.0
        case .secondary:
            backgroundColor = Theme.Color.surface
            setTitleColor(.white, for: .normal)
            trailingIcon.tintColor = .white
            isUserInteractionEnabled = true
            alpha = 1.0
        case .disabled:
            backgroundColor = Theme.Color.surface
            setTitleColor(Theme.Color.textTertiary, for: .normal)
            trailingIcon.tintColor = Theme.Color.textTertiary
            isUserInteractionEnabled = false
            alpha = 1.0
        }
    }
}
