//
//  OutlinedText.swift
//  DynamicAnimations
//
//  Created by Marty Avedon on 1/27/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import Foundation
import UIKit

// from http://stackoverflow.com/questions/1103148/how-do-i-make-uilabel-display-outlined-text
class OutlinedText: UILabel {
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = .white
    
    override func drawText(in rect: CGRect) {
        
        let strokeTextAttributes = [
            NSStrokeColorAttributeName : outlineColor,
            NSStrokeWidthAttributeName : -1 * outlineWidth, // making this negative gives a border around filled text; postive gives outlined text with a transparent fill
            ] as [String : Any]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}
