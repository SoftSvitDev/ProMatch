import UIKit
import SnapKit
import WebKit

final class TournamentViewController: UIViewController {
    private let url: URL
    private let navBar: NavBarView
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.backgroundColor = Theme.Color.background
        wv.isOpaque = false
        wv.scrollView.backgroundColor = Theme.Color.background
        wv.scrollView.indicatorStyle = .white
        wv.customUserAgent = RemoteConfigService.shared.getString(for: .wf78tgoc0oxkbw)
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()
    
    private let progressBar: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.Color.accent
        v.layer.cornerRadius = 1
        v.alpha = 0
        return v
    }()
    
    private var progressWidthConstraint: Constraint?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.color = Theme.Color.accent
        v.hidesWhenStopped = true
        return v
    }()
    
    private let errorView: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    
    private let errorIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "wifi.exclamationmark"))
        iv.tintColor = Theme.Color.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let errorTitle: UILabel = {
        let l = UILabel()
        l.text = "Can't load page"
        l.font = Theme.Font.bold(17)
        l.textColor = Theme.Color.textPrimary
        l.textAlignment = .center
        return l
    }()
    
    private let errorSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Check your internet connection and try again."
        l.font = Theme.Font.regular(13)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let retryButton = PrimaryButton(title: "Retry", style: .primary)

    private var progressObservation: NSKeyValueObservation?
    private var canGoBackObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?

    init(url: URL, title: String) {
        self.url = url
        self.navBar = NavBarView(title: title)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    required init?(coder: NSCoder) { fatalError() }

    deinit {
        progressObservation?.invalidate()
        canGoBackObservation?.invalidate()
        loadingObservation?.invalidate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        SettingsStore.shared.themeMode == .light ? .darkContent : .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background

        view.addSubview(navBar)
        view.addSubview(webView)
        view.addSubview(progressBar)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        errorView.addSubview(errorIcon)
        errorView.addSubview(errorTitle)
        errorView.addSubview(errorSubtitle)
        errorView.addSubview(retryButton)

        navBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.equalToSuperview()
            self.progressWidthConstraint = make.width.equalTo(0).constraint
            make.height.equalTo(2)
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(webView)
        }
        errorView.snp.makeConstraints { make in
            make.center.equalTo(webView)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        errorIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(44)
        }
        errorTitle.snp.makeConstraints { make in
            make.top.equalTo(errorIcon.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
        }
        errorSubtitle.snp.makeConstraints { make in
            make.top.equalTo(errorTitle.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(errorSubtitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(Theme.Metric.buttonHeight)
            make.bottom.equalToSuperview()
        }

        navBar.backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(load), for: .touchUpInside)
        webView.navigationDelegate = self

        observeProgress()
        observeCanGoBack()
        observeLoading()
        load()
    }

    private func observeLoading() {
        loadingObservation = webView.observe(\.isLoading, options: [.new]) { [weak self] webView, _ in
            DispatchQueue.main.async {
                if webView.isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInteractivePopGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore nav gesture for siblings on the stack.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func observeCanGoBack() {
        canGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] _, _ in
            self?.updateInteractivePopGesture()
        }
    }

    private func updateInteractivePopGesture() {
        // When the webview can navigate back, let its own edge-swipe handle the gesture.
        // Otherwise, restore the navigation controller's pop swipe.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !webView.canGoBack
    }

    private func observeProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self else { return }
            let value = CGFloat(webView.estimatedProgress)
            let totalWidth = self.view.bounds.width
            self.progressWidthConstraint?.update(offset: totalWidth * value)
            UIView.animate(withDuration: 0.2) {
                self.progressBar.alpha = value < 1 ? 1 : 0
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func load() {
        errorView.isHidden = true
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        webView.load(request)
    }

    @objc private func close() {
        if webView.canGoBack {
            webView.goBack()
            return
        }
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension TournamentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Hide any stale error from a previous attempt as soon as a new load begins.
        errorView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if isCancellationError(error) { return }
        showError()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if isCancellationError(error) { return }
        showError()
    }

    private func isCancellationError(_ error: Error) -> Bool {
        // NSURLErrorCancelled (-999) and WKWebKit frame-load interrupted (102)
        // both fire during legitimate back/forward navigation and should not be surfaced.
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled { return true }
        if nsError.domain == "WebKitErrorDomain" && (nsError.code == 102 || nsError.code == 101) { return true }
        return false
    }

    private func showError() {
        progressBar.alpha = 0
        errorView.isHidden = false
    }
}
