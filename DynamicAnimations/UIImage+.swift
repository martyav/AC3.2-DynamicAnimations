//
//  UIImage+.swift
//  DynamicAnimations
//
//  Created by Marty Avedon on 1/27/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    // from http://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-a-uiimage-in-swift-programmatically
    func alpha(value:CGFloat)->UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
