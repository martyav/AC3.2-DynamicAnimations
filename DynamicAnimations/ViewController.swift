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
    var snapBehavior: UISnapBehavior?
    var gravityBehavior: UIGravityBehavior?
    
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
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 90).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.isEnabled = true
        self.button.addTarget(self, action: #selector(snapToCenter(sender:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // we need to put gravity in here because if we put it in view did load, the box may not be drawn yet
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
    
        gravityBehavior = UIGravityBehavior(items: [box1])
        //gravityBehavior.angle = CGFloat.pi/6.0
        if let gravity = gravityBehavior {
            gravity.gravityDirection = CGVector(dx: -0.1, dy: -0.5)
        //let windBehavior = UIPushBehavior(items: [box1], mode: .instantaneous)
            self.dynamicAnimator?.addBehavior(gravity)
        }
        //self.dynamicAnimator?.addBehavior(windBehavior)
    }
    
    func snapToCenter(sender: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            snapBehavior = UISnapBehavior(item: box1, snapTo: self.view.center)
            self.dynamicAnimator?.addBehavior(snapBehavior!)
        } else {
            if let behavior = snapBehavior {
                self.dynamicAnimator?.removeBehavior(behavior)
            }
        }
    }
    
    internal lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Oh Snap!", for: .normal)
        button.setTitle("De-Snap", for: .selected)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()
}
