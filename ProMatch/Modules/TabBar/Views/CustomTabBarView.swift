import UIKit
import SnapKit

final class CustomTabBarView: UIView {
    struct Item {
        let title: String
        let symbol: String
    }

    private(set) var buttons: [TabBarItemButton] = []
    var onSelect: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0

    private let topDivider: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.divider
        return v
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.alignment = .fill
        return s
    }()

    init(items: [Item]) {
        super.init(frame: .zero)
        setupUI(items: items)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(items: [Item]) {
        backgroundColor = Theme.Color.background
        addSubview(topDivider)
        addSubview(stack)

        topDivider.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(60)
        }

        for (idx, item) in items.enumerated() {
            let btn = TabBarItemButton(title: item.title, symbol: item.symbol)
            btn.tag = idx
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }
        select(0)
    }

    func select(_ index: Int) {
        selectedIndex = index
        for (i, btn) in buttons.enumerated() {
            btn.setActive(i == index)
        }
    }

    @objc private func tapped(_ sender: TabBarItemButton) {
        select(sender.tag)
        onSelect?(sender.tag)
    }
}

final class TabBarItemButton: UIControl {
    let iconView = UIImageView()
    let titleLabel = UILabel()

    init(title: String, symbol: String) {
        super.init(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        iconView.tintColor = Theme.Color.textTertiary
        titleLabel.text = title
        titleLabel.font = Theme.Font.medium(11)
        titleLabel.textColor = Theme.Color.textTertiary
        titleLabel.textAlignment = .center
        addSubview(iconView)
        addSubview(titleLabel)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        iconView.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError() }

    func setActive(_ active: Bool) {
        let color = active ? Theme.Color.accent : Theme.Color.textTertiary
        iconView.tintColor = color
        titleLabel.textColor = color
        titleLabel.font = active ? Theme.Font.semibold(11) : Theme.Font.medium(11)
    }
}
