//
//  Pulsing.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 05/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class Pulsing: CALayer {
    
    var animationGroup = CAAnimationGroup()
    
    var initialPulseScale:TimeInterval = 0
    var nextPulseAfter:TimeInterval = 0
    var animationDuration:TimeInterval = 0.8
    var radius:CGFloat = 200
    var numberOfPulses:Float = Float.infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(numberOfPulses: Float, diameter: CGFloat, position: CGPoint, bgColor: UIColor = accentColor) {
        super.init()
        
        self.backgroundColor = bgColor.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = diameter/2
        self.numberOfPulses = numberOfPulses
        self.position = position
        
        self.bounds = CGRect(x: 0, y: 0, width: diameter * 2, height: diameter * 2)
        self.cornerRadius = diameter
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.setUpAnimationGroup()
            
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }
    
    func creatScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: initialPulseScale)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = animationDuration
        
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [0.1, 0.4, 0.1]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        return opacityAnimation
    }
    
    func setUpAnimationGroup() {

        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = animationDuration + nextPulseAfter
        self.animationGroup.repeatCount = -1
        //self.animationGroup.isRemovedOnCompletion = false
        //self.animationGroup.fillMode = kCAFillModeForwards
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [creatScaleAnimation(),createOpacityAnimation()]
    }
}
