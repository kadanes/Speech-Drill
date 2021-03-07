//
//  BadgeBarButton.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 07/03/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//  Ref: https://gist.github.com/freedom27/c709923b163e26405f62b799437243f4

import Foundation
import UIKit

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }

    func setBadge(text: String?, offset: CGPoint = .zero, color: UIColor = .red, filled: Bool = true, fontSize: CGFloat = 11.0) {
        badgeLayer?.removeFromSuperlayer()

        guard let text = text, !text.isEmpty else {
            return
        }
        self.addBadge(text: text, offset: offset, color: color, filled: filled)
    }

    private func addBadge(text: String, offset: CGPoint = .zero, color: UIColor = .red, filled: Bool = true, fontSize: CGFloat = 11) {
        
        guard let view = self.customView else { return }
        
        let font = getFont(name: .HelveticaNeueBold, size: .small)
        
        let badgeSize = text.size(withAttributes: [.font: font])

        // initialize Badge
        let badge = CAShapeLayer()

        let height = badgeSize.height
        var width = badgeSize.width + 4 // padding

        // make sure we have at least a circle
        if width < height {
            width = height
        }

        // x position is offset from right-hand side
        logger.debug("Nav button frame width: \(view.frame.width)")
        let x = view.frame.width + offset.x - 20
        let y = offset.y + 5
        
        let badgeFrame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))

        badge.drawRoundedRect(rect: badgeFrame, andColor: color, filled: filled)
        view.layer.addSublayer(badge)

        // initialiaze Badge's label
        let label = CATextLayer()
        label.string = text
        label.alignmentMode = kCAAlignmentCenter
        label.font = font
        label.fontSize = font.pointSize

        label.frame = badgeFrame
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)

        // save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // bring layer to front
        badge.zPosition = 1_000
    }

    private func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }

}

// MARK: - Utilities

extension CAShapeLayer {
    func drawRoundedRect(rect: CGRect, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        path = UIBezierPath(roundedRect: rect, cornerRadius: 7).cgPath
    }
}
