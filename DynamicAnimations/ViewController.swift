//
//  ViewController.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var box1: UIView!
    var dynamicAnimator: UIDynamicAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        box1 = UIView(frame: .zero)
        box1.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(box1)
        box1.backgroundColor = .blue
        box1.widthAnchor.constraint(equalToConstant: 150).isActive = true
        box1.heightAnchor.constraint(equalToConstant: 150).isActive = true
        box1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        box1.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        let gravityBehavior = UIGravityBehavior(items: [box1])
        self.dynamicAnimator?.addBehavior(gravityBehavior)
    }
    
}

