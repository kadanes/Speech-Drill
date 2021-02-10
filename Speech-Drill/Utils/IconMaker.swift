//
//  IconMaker.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

///Draw a circle of given diameter and return it as image
func drawSliderThumb(diameter: CGFloat, backgroundColor: UIColor) -> UIImage {
    logger.info("Drawing slider thumb icon")
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
    let img = renderer.image { ctx in
        ctx.cgContext.setFillColor(backgroundColor.cgColor)
        let rectangle = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.cgContext.addEllipse(in: rectangle)
        ctx.cgContext.drawPath(using: .fill)
    }
    return img
}
