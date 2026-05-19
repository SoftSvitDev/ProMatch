import UIKit
import SnapKit

final class OnboardingView: UIView {
    let skipButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Skip", for: .normal)
        b.setTitleColor(Theme.Color.textSecondary, for: .normal)
        b.titleLabel?.font = Theme.Font.medium(15)
        return b
    }()

    let illustrationContainer: UIView = {
        let v = UIView()
        return v
    }()

    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.bold(28)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = Theme.Font.regular(15)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    let pageIndicatorStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()

    let continueButton = PrimaryButton(
        title: "Continue",
        icon: UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configurePageIndicator(total: Int, currentIndex: Int) {
        pageIndicatorStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<total {
            let dot = UIView()
            dot.backgroundColor = (i == currentIndex) ? Theme.Color.accent : Theme.Color.textTertiary
            dot.layer.cornerRadius = 4
            pageIndicatorStack.addArrangedSubview(dot)
            dot.snp.makeConstraints { make in
                make.height.equalTo(8)
                make.width.equalTo(i == currentIndex ? 24 : 8)
            }
        }
    }
}

private extension OnboardingView {
    func setupUI() {
        backgroundColor = Theme.Color.background
        [skipButton, illustrationContainer, titleLabel, subtitleLabel,
         pageIndicatorStack, continueButton].forEach { addSubview($0) }
    }

    func setupConstraints() {
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(safeTop).offset(8)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(22)
        }
        illustrationContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(220)
            make.top.equalTo(safeTop).offset(160)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationContainer.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeBottom).offset(-24)
            make.height.equalTo(Theme.Metric.buttonHeight)
        }
        pageIndicatorStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-24)
        }
    }
}
