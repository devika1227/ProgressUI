//
//  MultiColorActivityIndicator.swift
//  ProgressUI
//
//  Created by Devika on 08/11/2026.
//

import UIKit

class MultiColorActivityIndicator: NSObject, CAAnimationDelegate {
    
    private var view: UIView {
        if #available(iOS 13.0, *) {
            var keyWindow: UIWindow? {
                return UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
                
            }
            return keyWindow ?? UIView()
        } else {
            if let window = UIApplication.shared.keyWindow{
                return window
            }
        }

        return UIView()
    }
    
    var colorChangeArr = [UIColor.init(red: 40/255, green: 170/255, blue: 226/255, alpha: 1.0).cgColor, UIColor.init(red: 58/255, green: 216/255, blue: 48/255, alpha: 1.0).cgColor]
    var arrPostionIndex = 0
    var endFlag = false
    var dismissFlag = false
    let shapeLayer = CAShapeLayer()
    let progressView = UIView()
    
    func show() {
        view.isUserInteractionEnabled = false
        //Create a progress view
        progressView.frame = CGRect(x: view.frame.midX / 2 ,y: view.frame.midY / 2, width: 100, height: 100)
        progressView.center = view.center
        progressView.backgroundColor = .clear
        view.addSubview(progressView)
        
        var endAngle = 2 * CGFloat.pi
        if endFlag == true {
            endAngle = (-CGFloat.pi / 2) + 0.1
        }
        
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 50.0, y: 50.0), radius: 20, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)

        // Create track layer
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        progressView.layer.addSublayer(trackLayer)
  
        
        // Create a stroke circle layer
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        
        if arrPostionIndex == 0 {
            shapeLayer.strokeColor = colorChangeArr[arrPostionIndex]
            if endFlag == false{
                arrPostionIndex = 1
            }
        } else {
            shapeLayer.strokeColor = colorChangeArr[arrPostionIndex]
            if endFlag == false{
                arrPostionIndex = 0
            }
        }
        
        progressView.layer.addSublayer(shapeLayer)
                              
        // Stroke animation
        CATransaction.begin()
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 0.6
        basicAnimation.fillMode = .forwards
        basicAnimation.repeatCount = 1
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.delegate = self
        shapeLayer.add(basicAnimation, forKey: "progressLoad")
        CATransaction.commit()
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if endFlag == true {
            endFlag = false
        } else {
            endFlag = true
        }

        if dismissFlag == false {
            show()
        }
    }
    
    func dismiss() {
        dismissFlag = true
        view.isUserInteractionEnabled = true
        progressView.removeFromSuperview()
    }
}
