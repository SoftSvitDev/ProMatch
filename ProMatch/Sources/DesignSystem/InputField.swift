import UIKit

final class LabeledTextField: UIView {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.medium(12)
        l.textColor = Theme.Color.textSecondary
        return l
    }()

    let textField: PaddedTextField = {
        let tf = PaddedTextField()
        tf.font = Theme.Font.regular(15)
        tf.textColor = .white
        tf.backgroundColor = Theme.Color.inputBackground
        tf.layer.cornerRadius = Theme.Metric.inputRadius
        tf.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [.foregroundColor: Theme.Color.textTertiary]
        )
        return tf
    }()

    init(title: String, placeholder: String, keyboard: UIKeyboardType = .default) {
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        titleLabel.attributedText = NSAttributedString(
            string: title.uppercased(),
            attributes: [.foregroundColor: Theme.Color.textSecondary,
                         .kern: 0.5,
                         .font: Theme.Font.semibold(11)]
        )
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Theme.Color.textTertiary,
                         .font: Theme.Font.regular(15)]
        )
        textField.keyboardType = keyboard
        addSubview(titleLabel)
        addSubview(textField)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

final class PaddedTextField: UITextField {
    var padding = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
}

final class SectionHeaderLabel: UILabel {
    init(_ text: String) {
        super.init(frame: .zero)
        self.attributedText = NSAttributedString(
            string: text.uppercased(),
            attributes: [.foregroundColor: Theme.Color.textSecondary,
                         .kern: 0.5,
                         .font: Theme.Font.semibold(11)]
        )
    }
    required init?(coder: NSCoder) { fatalError() }
}
