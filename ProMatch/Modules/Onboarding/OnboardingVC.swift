import UIKit
import SnapKit

struct OnboardingPage {
    let title: String
    let subtitle: String
    let illustration: () -> UIView
}

final class OnboardingViewController: UIViewController {
    private var onboardingView: OnboardingView { view as! OnboardingView }
    private var currentIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Manage your squad",
            subtitle: "Build rosters, assign positions, track every\nplayer",
            illustration: { OnboardingViewController.makeImageView(named: "onb1") }
        ),
        OnboardingPage(
            title: "Run your tournaments",
            subtitle: "Round-robin, knockout, or group stage — set it\nup in seconds",
            illustration: { OnboardingViewController.makeImageView(named: "onb2") }
        ),
        OnboardingPage(
            title: "Track every match",
            subtitle: "Live standings, scorers, and match history at your\nfingertips",
            illustration: { OnboardingViewController.makeImageView(named: "onb3") }
        ),
        OnboardingPage(
            title: "You're all set",
            subtitle: "Start by creating your first\nteam",
            illustration: { OnboardingViewController.makeImageView(named: "onb4") }
        ),
    ]

    private static func makeImageView(named name: String) -> UIImageView {
        let iv = UIImageView(image: UIImage(named: name))
        iv.contentMode = .scaleAspectFit
        return iv
    }

    var onFinish: (() -> Void)?

    override func loadView() { view = OnboardingView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingView.skipButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        onboardingView.continueButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        showPage(0)
    }

    private func showPage(_ index: Int) {
        currentIndex = index
        let page = pages[index]
        onboardingView.titleLabel.text = page.title
        onboardingView.subtitleLabel.text = page.subtitle
        onboardingView.illustrationContainer.subviews.forEach { $0.removeFromSuperview() }
        let illo = page.illustration()
        onboardingView.illustrationContainer.addSubview(illo)
        illo.snp.makeConstraints { $0.edges.equalToSuperview() }
        onboardingView.configurePageIndicator(total: pages.count, currentIndex: index)
    }

    @objc private func nextTapped() {
        if currentIndex < pages.count - 1 {
            showPage(currentIndex + 1)
        } else {
            finish()
        }
    }

    @objc private func finish() {
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
        onFinish?()
    }
}
