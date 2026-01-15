//
//  ProgressBar.swift
//  CountdownTimer
//
//  Created by Jonni Akesson on 2017-04-20.
//  Copyright © 2017 Jonni Akesson. All rights reserved.
//

import UIKit

/// A custom circular progress bar view.
/// Managed reactively via `setProgress(_:)`.
class ProgressBar: UIView {
    
    // MARK: - Layer Properties
    lazy var fgProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 4.0
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
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
        let colorTop = Theme.Colors.spotifyGreen.cgColor
        let colorBottom = Theme.Colors.spotifyGreen.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.mask = fgProgressLayer
        return gradientLayer
    }()
    
    lazy var bgGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        let colorTop = Theme.Colors.darkGray.cgColor
        let colorBottom = Theme.Colors.darkGray.cgColor // Same color effectively solid, but keeps gradient structure
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
    
    public func setProgress(_ progress: Float) {
        // progress is 0.0 (start) -> 1.0 (done).
        // We want the ring to be full at start (1.0) and empty at done (0.0).
        // So strokeEnd = 1.0 - progress.
        fgProgressLayer.strokeEnd = CGFloat(1.0 - progress)
    }
    
    /// Resets the progress bar to the finished (empty) state.
    public func stop() {
        setProgress(0.0)
    }
}
