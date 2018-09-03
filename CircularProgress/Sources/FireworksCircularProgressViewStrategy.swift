//
//  Created by Brian Coyner on 9/3/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit

/// A `CircularProgressViewStrategy` with the following characteristics.
///
/// Background Layer
/// - displays a thin circle.
/// - circular path color is based on the tint color.
/// - rotates with an open gap in the indeterminate state.
///
/// Progress Layer
/// - displays a circular path that hugs the inside of the background circle.
/// - circular path color is based on the tint color.
/// - invisible in the indeterminate state.
///
/// Custom Content
/// - this strategy requires a `CircularProgressViewAdditionalContentLayoutStrategy` implementation.
/// - most usages will use the `RoundedRectAdditionalContentLayoutStrategy` to display a small rounded rect (i.e. stop).
/// - visible in all states
///
/// This strategy is commonly used when displaying a list or grid view of downloadable assets.

public final class FireworksCircularProgressViewStrategy: CircularProgressViewStrategy {

    fileprivate let additionalContentLayoutStrategy: CircularProgressViewAdditionalContentLayoutStrategy

    fileprivate lazy var emitterLayer = self.lazyEmitterLayer()

    public init(additionalContentLayoutStrategy: CircularProgressViewAdditionalContentLayoutStrategy) {
        self.additionalContentLayoutStrategy = additionalContentLayoutStrategy
    }
}

extension FireworksCircularProgressViewStrategy {

    public func layoutLayers(_ layers: CircularProgressView.Layers, center: CGPoint, radius: CGFloat) {
        layers.backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius).cgPath
        layers.backgroundLayer.lineWidth = backgroundLayerLineWidth(basedOn: radius)

        layers.progressLayer.path = progressPath(for: center, radius: radius, angle: 0)
        layers.progressLayer.lineWidth = progressLayerLineWidth(basedOn: radius)

        layers.backgroundLayer.addSublayer(emitterLayer)

        emitterLayer.position = center

        additionalContentLayoutStrategy.layoutAdditionalContent(in: layers.additionalContentLayer, center: center, radius: radius)
    }
}

extension FireworksCircularProgressViewStrategy {

    public func transitionLayers(_ layers: CircularProgressView.Layers, to state: CircularProgressView.State, tintColor: UIColor) {
        animateLayers(layers, to: state)
        additionalContentLayoutStrategy.transitionAdditionalContent(to: state, tintColor: tintColor)
    }
}

extension FireworksCircularProgressViewStrategy {

    public func updateTintColor(_ tintColor: UIColor, on layers: CircularProgressView.Layers, state: CircularProgressView.State) {
        layers.backgroundLayer.fillColor = UIColor.clear.cgColor
        layers.backgroundLayer.strokeColor = tintColor.cgColor

        layers.progressLayer.fillColor = UIColor.clear.cgColor
        layers.progressLayer.strokeColor = tintColor.cgColor

        updateEmitterLayerTintColor(to: tintColor)

        additionalContentLayoutStrategy.updateTintColor(tintColor, state: state)
    }
}

extension FireworksCircularProgressViewStrategy {

    public func progressPath(for center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPath {

        let cosEndAngle = cos(angle)
        let sinEndAngle = sin(angle)

        emitterLayer.position = CGPoint(
            x: center.x + (radius * cosEndAngle),
            y: center.y + (radius * sinEndAngle)
        )

        return UIBezierPath(
            arcCenter: center,
            radius: progressLayerRadius(basedOn: radius),
            startAngle: 0.0,
            endAngle: angle,
            clockwise: true
        ).cgPath
    }
}

extension FireworksCircularProgressViewStrategy {

    private func animateLayers(_ layers: CircularProgressView.Layers, to state: CircularProgressView.State) {
        switch state {
        case .indeterminate:

            addIndeterminateAnimation(to: layers.backgroundLayer)
            layers.progressLayer.opacity = 0.0
        case .progress(_):
            layers.progressLayer.opacity = 1.0
            removeIndeterminateAnimation(from: layers.backgroundLayer)
        }
    }

    private func addIndeterminateAnimation(to indeterminateLayer: CAShapeLayer) {
        indeterminateLayer.strokeStart = 0.0
        indeterminateLayer.strokeEnd = 0.9

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber(value: (2.0 * .pi) - (.pi / 2.0))
        animation.autoreverses = false
        animation.repeatCount = .greatestFiniteMagnitude
        animation.duration = 1.6

        indeterminateLayer.add(animation, forKey: String(describing: FireworksCircularProgressViewStrategy.self))
    }

    private func removeIndeterminateAnimation(from indeterminateLayer: CAShapeLayer) {
        guard let animation = indeterminateLayer.animation(forKey: String(describing: FireworksCircularProgressViewStrategy.self)) as? CABasicAnimation else {
            return
        }

        guard animation.keyPath == "transform.rotation.z" else {
            return
        }

        indeterminateLayer.strokeStart = 0.0
        indeterminateLayer.strokeEnd = 1.0

        indeterminateLayer.removeAnimation(forKey: String(describing: FireworksCircularProgressViewStrategy.self))

        indeterminateLayer.add(CABasicAnimation(), forKey: String(describing: StrokedCircularProgressViewStrategy.self))
    }
}

extension FireworksCircularProgressViewStrategy {

    private func backgroundLayerLineWidth(basedOn radius: CGFloat) -> CGFloat {
        return floor(max(radius * 0.08, 2.0))
    }

    private func progressLayerLineWidth(basedOn radius: CGFloat) -> CGFloat {
        return floor(max(radius * 0.15, 2.0))
    }

    private func progressLayerRadius(basedOn radius: CGFloat) -> CGFloat {
        return radius - ((backgroundLayerLineWidth(basedOn: radius) + progressLayerLineWidth(basedOn: radius)) / 2) + 0.5
    }
}

extension FireworksCircularProgressViewStrategy {

    fileprivate func lazyEmitterLayer() -> CAEmitterLayer {

        // Generates an interesting "sparkle" particle system.
        
        let emitterLayer = CAEmitterLayer()

        let spark = CAEmitterCell()
        spark.birthRate = 250

        spark.lifetime = 2
        spark.lifetimeRange = 2

        spark.speed = 5

        spark.alphaRange = 1
        spark.alphaSpeed = 1

        spark.emissionRange = 0
        spark.emissionRange = .pi * 2
        spark.velocity = 200
        spark.velocityRange = 50

        spark.xAcceleration = 0
        spark.yAcceleration = 0
        spark.zAcceleration = 0

        spark.scale = 0.235
        spark.scaleRange = 0.4
        spark.scaleSpeed = -0.5

        spark.contents = UIImage(named: "Spark")!.cgImage!

        spark.greenRange = 1
        spark.redRange = 0.75
        spark.blueRange = 0.5

        emitterLayer.emitterCells = [spark]


        return emitterLayer
    }

    fileprivate func updateEmitterLayerTintColor(to tintColor: UIColor) {
        emitterLayer.emitterCells?.forEach({
            $0.color = tintColor.cgColor
        })

        // It appears that CAEmitterLayer won't pick up the cell color change
        // unless we "reset" the layers. This hack seems to work.
        let original = emitterLayer.emitterCells
        emitterLayer.emitterCells = []
        emitterLayer.emitterCells = original
    }
}
