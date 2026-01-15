//
//  ProgressBar.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import UIKit

class ProgressBar: UIView, CAAnimationDelegate {
    
    fileprivate var animation = CABasicAnimation()
    fileprivate var animationDidStart = false
    fileprivate var timerDuration = 0
    
    lazy var fgProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 4.0
        layer.strokeStart = 0.0
        layer.strokeEnd = 0.0
        return layer
    }()
    
    lazy var bgProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 4.0
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        return layer
    }()
    
    lazy var fgGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        let colorTop = CustomColor.lime.cgColor
        let colorBottom = CustomColor.summerSky.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.mask = fgProgressLayer
        return gradientLayer
    }()
    
    lazy var bgGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        let colorTop = CustomColor.flipside.cgColor
        let colorBottom = CustomColor.flipside.cgColor // Same color effectively solid, but keeps gradient structure
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.mask = bgProgressLayer
        return gradientLayer
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    fileprivate func setupLayers() {
        layer.addSublayer(bgGradientLayer)
        layer.addSublayer(fgGradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let startAngle = CGFloat(-Double.pi / 2)
        let endAngle = CGFloat(3 * Double.pi / 2)
        let centerPoint = CGPoint(x: bounds.width/2 , y: bounds.height/2)
        let radius = max(0, min(bounds.width, bounds.height)/2 - 30.0)
        
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        
        // Update Background
        bgGradientLayer.frame = bounds
        bgProgressLayer.frame = bounds
        bgProgressLayer.path = path
        
        // Update Foreground
        fgGradientLayer.frame = bounds
        fgProgressLayer.frame = bounds
        fgProgressLayer.path = path
    }
    
    public func setProgressBar(hours:Int, minutes:Int, seconds:Int) {
        let hoursToSeconds = hours * 3600
        let minutesToSeconds = minutes * 60
        let totalSeconds = seconds + minutesToSeconds + hoursToSeconds
        timerDuration = totalSeconds
    }
    
    public func start() {
        if !animationDidStart {
            startAnimation()
        }else{
            resumeAnimation()
        }
    }
    
    public func pause() {
        pauseAnimation()
    }
    
    public func stop() {
        stopAnimation()
    }
    
    
    fileprivate func startAnimation() {
        
        resetAnimation()
        
        fgProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = CGFloat(0.0)
        animation.toValue = CGFloat(1.0)
        animation.duration = CFTimeInterval(timerDuration)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        fgProgressLayer.add(animation, forKey: "strokeEnd")
        animationDidStart = true
        
    }
    
    
    fileprivate func resetAnimation() {
        fgProgressLayer.speed = 1.0
        fgProgressLayer.timeOffset = 0.0
        fgProgressLayer.beginTime = 0.0
        fgProgressLayer.strokeEnd = 0.0
        animationDidStart = false
    }
    
    
    fileprivate func stopAnimation() {
        fgProgressLayer.speed = 1.0
        fgProgressLayer.timeOffset = 0.0
        fgProgressLayer.beginTime = 0.0
        fgProgressLayer.strokeEnd = 0.0
        fgProgressLayer.removeAllAnimations()
        animationDidStart = false
    }
    
    
    fileprivate func pauseAnimation(){
        let pausedTime = fgProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        fgProgressLayer.speed = 0.0
        fgProgressLayer.timeOffset = pausedTime
        
    }
    
    
    fileprivate func resumeAnimation(){
        let pausedTime = fgProgressLayer.timeOffset
        fgProgressLayer.speed = 1.0
        fgProgressLayer.timeOffset = 0.0
        fgProgressLayer.beginTime = 0.0
        fgProgressLayer.beginTime = fgProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
             stopAnimation()
        }
    }
    
}
