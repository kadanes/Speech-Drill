//
//  UIScrollView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 29/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    var minContentOffset: CGPoint {
        return CGPoint(
            x: -contentInset.left,
            y: -contentInset.top)
    }
    
    var maxContentOffset: CGPoint {
        return CGPoint(
            x: contentSize.width - bounds.width + contentInset.right,
            y: contentSize.height - bounds.height + contentInset.bottom)
    }
    
    func scrollToMinContentOffset(animated: Bool) {
        setContentOffset(minContentOffset, animated: animated)
    }
    
    func scrollToMaxContentOffset(animated: Bool) {
        setContentOffset(maxContentOffset, animated: animated)
    }
}
