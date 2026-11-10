//
//  CircularProgressView.swift
//  ProgressUI
//
//  Created by Devika on 08/11/2026.
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    private let percentageLabel = UILabel()
        
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var fromValue: CGFloat = 0
    private var toValue: CGFloat = 0
    private var animationDuration: TimeInterval = 1
    private var lastLabelValue: Int = 0
    
    var progress: CGFloat {
        return progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
    }
    
    var lineWidth: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? iPadLineWidth : iPhoneLineWidth
    }
    
    @IBInspectable var iPhoneLineWidth: CGFloat = 5.0 {
        didSet {
            if UIDevice.current.userInterfaceIdiom == .phone {
                updateLayers()
            }
        }
    }
    
    @IBInspectable var iPadLineWidth: CGFloat = 10.0 {
        didSet {
            if UIDevice.current.userInterfaceIdiom == .pad {
                updateLayers()
            }
        }
    }

    @IBInspectable var progressColor: UIColor = .blue {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }

    @IBInspectable var trackColor: UIColor = .lightGray {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }

    @IBInspectable var innerCircleColor: UIColor = .white {
        didSet { innerCircleLayer.fillColor = innerCircleColor.cgColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    func setProgress(to value: CGFloat, duration: TimeInterval = 1, completion: (() -> Void)? = nil) {
        stopCurrentAnimations()
        
        let clampedValue = min(max(value, 0), 1)
        let currentValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        
        if abs(currentValue - clampedValue) < 0.01 || duration < 0.1 {
            setProgressWithoutAnimation(to: clampedValue)
            completion?()
            return
        }
        
        // Configure progress layer animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = currentValue
        animation.toValue = clampedValue
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // CATransaction for precise completion handling
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        progressLayer.strokeEnd = clampedValue
        progressLayer.add(animation, forKey: "progressAnimation")
        CATransaction.commit()
        
        // Configure label animation
        fromValue = currentValue
        toValue = clampedValue
        animationDuration = duration
        lastLabelValue = Int(currentValue * 100)
        animationStartTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateLabel))
        displayLink?.preferredFramesPerSecond = 30
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func setProgressWithoutAnimation(to value: CGFloat) {
        stopCurrentAnimations()
        let clampedValue = min(max(value, 0), 1)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = clampedValue
        CATransaction.commit()
        updateLabelText(Int(clampedValue * 100))
    }
    
    func stopAllProgressAnimations() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let currentProgress = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        
        stopCurrentAnimations()
        progressLayer.strokeEnd = currentProgress
        updateLabelText(Int(currentProgress * 100))
        
        CATransaction.commit()
    }
    
    // MARK: - Private Methods
    private func setupLayers() {
        backgroundColor = .clear
        layer.addSublayer(innerCircleLayer)
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)

        innerCircleLayer.fillColor = innerCircleColor.cgColor

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .butt
    }

    private func setupLabel() {
        self.percentageLabel.textAlignment = .center
        self.percentageLabel.backgroundColor = .clear
        self.percentageLabel.textColor = progressColor
        self.percentageLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        self.percentageLabel.numberOfLines = 1
        self.percentageLabel.text = "0"
        
        let symbolLabel = UILabel()
        symbolLabel.textAlignment = .center
        symbolLabel.textColor = .blue
        symbolLabel.backgroundColor = .clear
        symbolLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        symbolLabel.numberOfLines = 1
        symbolLabel.text = "%"
               
        let stackView = UIStackView(arrangedSubviews: [percentageLabel, symbolLabel])
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .firstBaseline
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add stack view as subview
        addSubview(stackView)
        
        // Center stack view inside the progress view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = 1.5 * .pi

        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        trackLayer.path = circularPath.cgPath
        trackLayer.frame = bounds

        progressLayer.path = circularPath.cgPath
        progressLayer.frame = bounds

        let innerRadius = radius - lineWidth / 2
        let innerPath = UIBezierPath(
            arcCenter: center,
            radius: innerRadius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        innerCircleLayer.path = innerPath.cgPath
        innerCircleLayer.frame = bounds
    }

    private func stopCurrentAnimations() {
        displayLink?.invalidate()
        displayLink = nil
        progressLayer.removeAnimation(forKey: "progressAnimation")
    }
    
    private func updateLabelText(_ value: Int) {
        if lastLabelValue != value {
            percentageLabel.text = "\(value)"
            lastLabelValue = value
        }
    }

    @objc private func updateLabel() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        
        if elapsed >= animationDuration {
            updateLabelText(Int(toValue * 100))
            displayLink?.invalidate()
            displayLink = nil
            return
        }

        let progress = easeInEaseOut(CGFloat(elapsed / animationDuration))
        let currentValue = fromValue + (toValue - fromValue) * progress
        updateLabelText(Int(currentValue * 100))
    }
    
    private func easeInEaseOut(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? 2 * x * x : -1 + (4 - 2 * x) * x
    }
}
