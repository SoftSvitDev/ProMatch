import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    var onFinish: (() -> Void)?

    private let ballContainer = UIView()
    private let ballView = AnimatedSoccerBallView()
    private let pitchLineLayer = CAShapeLayer()
    private let shadowLayer = CAShapeLayer()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "ProMatch"
        l.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        l.textColor = Theme.Color.textPrimary
        l.textAlignment = .center
        l.alpha = 0
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Manage every match"
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        l.textColor = Theme.Color.textSecondary
        l.textAlignment = .center
        l.alpha = 0
        return l
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background

        view.layer.addSublayer(pitchLineLayer)
        view.addSubview(ballContainer)
        ballContainer.addSubview(ballView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        ballContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.size.equalTo(140)
        }
        ballView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(ballView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        pitchLineLayer.fillColor = UIColor.clear.cgColor
        pitchLineLayer.strokeColor = Theme.Color.accent.withAlphaComponent(0.35).cgColor
        pitchLineLayer.lineWidth = 1.5
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPitchLines()
    }

    private func layoutPitchLines() {
        let bounds = view.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY - 40)
        let path = UIBezierPath()
        // Center circle
        path.append(UIBezierPath(arcCenter: center, radius: 110, startAngle: 0, endAngle: .pi * 2, clockwise: true))
        // Halfway line
        let lineY = center.y
        path.move(to: CGPoint(x: 24, y: lineY))
        path.addLine(to: CGPoint(x: center.x - 110, y: lineY))
        path.move(to: CGPoint(x: center.x + 110, y: lineY))
        path.addLine(to: CGPoint(x: bounds.width - 24, y: lineY))
        pitchLineLayer.path = path.cgPath
        pitchLineLayer.opacity = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAnimation()
    }

    private func playAnimation() {
        // Phase 1: ball starts above the visible area and drops with bounce.
        let bounds = view.bounds
        let dropDistance = bounds.height * 0.6
        ballContainer.transform = CGAffineTransform(translationX: 0, y: -dropDistance).scaledBy(x: 0.7, y: 0.7)
        ballContainer.alpha = 0

        // Bounce-drop appearance
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: { [self] in
                ballContainer.transform = .identity
                ballContainer.alpha = 1
            }
        )

        // Continuous rotation while it descends + settles
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = -CGFloat.pi * 1.2
        rotation.toValue = 0
        rotation.duration = 0.7
        rotation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        ballView.layer.add(rotation, forKey: "rotate-in")

        // Phase 2: pitch lines wipe in
        let pitchAnim = CABasicAnimation(keyPath: "opacity")
        pitchAnim.fromValue = 0
        pitchAnim.toValue = 1
        pitchAnim.duration = 0.35
        pitchAnim.beginTime = CACurrentMediaTime() + 0.55
        pitchAnim.fillMode = .forwards
        pitchAnim.isRemovedOnCompletion = false
        pitchLineLayer.add(pitchAnim, forKey: "fadeIn")

        // Phase 3: title + subtitle fade up
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 14)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 14)
        UIView.animate(withDuration: 0.45, delay: 0.7, options: [.curveEaseOut], animations: { [self] in
            titleLabel.alpha = 1
            titleLabel.transform = .identity
        })
        UIView.animate(withDuration: 0.45, delay: 0.85, options: [.curveEaseOut], animations: { [self] in
            subtitleLabel.alpha = 1
            subtitleLabel.transform = .identity
        })

        // Phase 4: a small "settle" idle bounce of the ball after it lands.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.idleBounce()
        }

        // Finish.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) { [weak self] in
            self?.finish()
        }
    }

    private func idleBounce() {
        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0, -8, 0, -3, 0]
        bounce.keyTimes = [0, 0.25, 0.55, 0.8, 1.0]
        bounce.duration = 0.6
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ballContainer.layer.add(bounce, forKey: "settle")
    }

    private func finish() {
        onFinish?()
    }
}

/// Pentagons-on-sphere soccer ball drawn with CoreGraphics, sized to the view bounds.
final class AnimatedSoccerBallView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override class var layerClass: AnyClass { CAShapeLayer.self }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - 8

        // Outer glow ring.
        ctx.setStrokeColor(Theme.Color.accent.withAlphaComponent(0.25).cgColor)
        ctx.setLineWidth(8)
        ctx.addArc(center: center, radius: outerRadius + 5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Solid outline.
        ctx.setStrokeColor(Theme.Color.accent.cgColor)
        ctx.setLineWidth(3)
        ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Filled inner disc (slightly darker than background).
        ctx.setFillColor(Theme.Color.surface.cgColor)
        ctx.addArc(center: center, radius: outerRadius - 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.fillPath()

        // Pentagon stitch.
        let pentagonRadius = outerRadius * 0.55
        var pentagon: [CGPoint] = []
        for i in 0..<5 {
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi * 2 / 5)
            pentagon.append(CGPoint(x: center.x + cos(angle) * pentagonRadius,
                                    y: center.y + sin(angle) * pentagonRadius))
        }
        ctx.setStrokeColor(Theme.Color.accent.cgColor)
        ctx.setLineWidth(2)
        ctx.move(to: pentagon[0])
        for p in pentagon.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath()
        ctx.strokePath()

        // Lines from pentagon vertices outward to circle.
        ctx.setStrokeColor(Theme.Color.accent.withAlphaComponent(0.85).cgColor)
        ctx.setLineWidth(2)
        for p in pentagon {
            let dx = p.x - center.x, dy = p.y - center.y
            let len = sqrt(dx*dx + dy*dy)
            let outerPoint = CGPoint(
                x: center.x + dx / len * (outerRadius - 2),
                y: center.y + dy / len * (outerRadius - 2)
            )
            ctx.move(to: p)
            ctx.addLine(to: outerPoint)
            ctx.strokePath()
        }

        // Inner star — gives a little "spinning" feel when the ball rotates.
        let starOuter = pentagonRadius * 0.42
        let starInner = starOuter * 0.42
        var star: [CGPoint] = []
        for i in 0..<10 {
            let r = (i % 2 == 0) ? starOuter : starInner
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 5)
            star.append(CGPoint(x: center.x + cos(angle) * r,
                                y: center.y + sin(angle) * r))
        }
        ctx.move(to: star[0])
        for p in star.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath()
        ctx.setFillColor(Theme.Color.accent.cgColor)
        ctx.fillPath()
    }
}
