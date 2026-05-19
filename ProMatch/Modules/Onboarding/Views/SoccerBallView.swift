import UIKit

final class SoccerBallView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2 - 8

        ctx.setStrokeColor(Theme.Color.accent.cgColor)
        ctx.setLineWidth(3)
        ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        ctx.setStrokeColor(Theme.Color.accent.withAlphaComponent(0.4).cgColor)
        ctx.setLineWidth(6)
        ctx.addArc(center: center, radius: outerRadius + 4, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        let innerRadius = outerRadius * 0.55
        var pentagonPoints: [CGPoint] = []
        for i in 0..<5 {
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi * 2 / 5)
            pentagonPoints.append(CGPoint(x: center.x + cos(angle) * innerRadius,
                                          y: center.y + sin(angle) * innerRadius))
        }

        ctx.setStrokeColor(Theme.Color.accent.cgColor)
        ctx.setLineWidth(2)
        ctx.move(to: pentagonPoints[0])
        for p in pentagonPoints.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath()
        ctx.strokePath()

        let starOuter = innerRadius * 0.35
        let starInner = starOuter * 0.4
        var starPoints: [CGPoint] = []
        for i in 0..<10 {
            let radius = (i % 2 == 0) ? starOuter : starInner
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (.pi / 5)
            starPoints.append(CGPoint(x: center.x + cos(angle) * radius,
                                      y: center.y + sin(angle) * radius))
        }
        ctx.move(to: starPoints[0])
        for p in starPoints.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath()
        ctx.setFillColor(Theme.Color.accent.cgColor)
        ctx.fillPath()

        for p in pentagonPoints {
            let outerPoint = CGPoint(
                x: center.x + (p.x - center.x) / innerRadius * outerRadius,
                y: center.y + (p.y - center.y) / innerRadius * outerRadius
            )
            ctx.setStrokeColor(Theme.Color.accent.cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: p)
            ctx.addLine(to: outerPoint)
            ctx.strokePath()
        }
    }
}

final class TournamentIllustrationView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        let bracketX: CGFloat = rect.width * 0.18
        let boxWidth: CGFloat = 50
        let boxHeight: CGFloat = 22
        let radius: CGFloat = 6

        ctx.setFillColor(Theme.Color.surface.cgColor)
        let topY = rect.height * 0.30
        let secondY = rect.height * 0.40
        let thirdY = rect.height * 0.55
        let fourthY = rect.height * 0.65

        for y in [topY, secondY, thirdY, fourthY] {
            let p = UIBezierPath(roundedRect: CGRect(x: bracketX, y: y, width: boxWidth, height: boxHeight), cornerRadius: radius)
            ctx.addPath(p.cgPath)
            ctx.fillPath()
        }

        ctx.setStrokeColor(Theme.Color.accent.withAlphaComponent(0.6).cgColor)
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint(x: bracketX + boxWidth, y: topY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 20, y: topY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 20, y: secondY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth, y: secondY + boxHeight / 2))
        ctx.strokePath()

        let midY = (topY + secondY) / 2 + boxHeight / 2
        ctx.move(to: CGPoint(x: bracketX + boxWidth + 20, y: midY))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 50, y: midY))
        ctx.strokePath()

        ctx.move(to: CGPoint(x: bracketX + boxWidth, y: thirdY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 20, y: thirdY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 20, y: fourthY + boxHeight / 2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth, y: fourthY + boxHeight / 2))
        ctx.strokePath()

        let midY2 = (thirdY + fourthY) / 2 + boxHeight / 2
        ctx.move(to: CGPoint(x: bracketX + boxWidth + 20, y: midY2))
        ctx.addLine(to: CGPoint(x: bracketX + boxWidth + 50, y: midY2))
        ctx.strokePath()

        let finalBox = CGRect(x: bracketX + boxWidth + 50, y: (midY + midY2) / 2 - boxHeight, width: boxWidth + 10, height: boxHeight)
        let finalPath = UIBezierPath(roundedRect: finalBox, cornerRadius: radius)
        ctx.setFillColor(Theme.Color.accent.withAlphaComponent(0.18).cgColor)
        ctx.addPath(finalPath.cgPath)
        ctx.fillPath()
        ctx.setStrokeColor(Theme.Color.accent.cgColor)
        ctx.setLineWidth(1.5)
        ctx.addPath(finalPath.cgPath)
        ctx.strokePath()

        let finalText = "FINAL" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: Theme.Font.bold(9),
            .foregroundColor: Theme.Color.accent
        ]
        let size = finalText.size(withAttributes: attrs)
        finalText.draw(at: CGPoint(x: finalBox.midX - size.width / 2, y: finalBox.midY - size.height / 2), withAttributes: attrs)

        let trophyCenter = CGPoint(x: finalBox.midX, y: finalBox.maxY + 28)
        let trophy = "🏆" as NSString
        let trophyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 40)]
        let trophySize = trophy.size(withAttributes: trophyAttrs)
        trophy.draw(at: CGPoint(x: trophyCenter.x - trophySize.width / 2, y: trophyCenter.y - trophySize.height / 2),
                    withAttributes: trophyAttrs)
    }
}
