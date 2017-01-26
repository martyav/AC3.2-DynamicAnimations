//
//  ViewController.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var animator: UIViewPropertyAnimator!
    var ball: UIView!
    var dynamicAnimator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior?
    var gravityBehavior: UIGravityBehavior?
    var collissionBehavior: UICollisionBehavior?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = true
        
        ball = UIView(frame: .zero)
        ball.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ball)
        ball.backgroundColor = .red
        ball.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalTo(50)
            view.height.equalTo(50)
        }
        
        ball.layer.cornerRadius = 25
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
        self.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6) {
            self.view.layoutIfNeeded()
        }

        /*
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 90).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.isEnabled = true
        self.button.addTarget(self, action: #selector(snapToCenter(sender:)), for: .touchUpInside)
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // we need to put gravity in here because if we put it in view did load, the ball may not be drawn yet
        
    }
    
    /*func snapToCenter(sender: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            snapBehavior = UISnapBehavior(item: ball, snapTo: self.view.center)
            self.dynamicAnimator?.addBehavior(snapBehavior!)
        } else {
            if let behavior = snapBehavior {
                self.dynamicAnimator?.removeBehavior(behavior)
            }
        }
    }
     */
    
    internal func move(view: UIView, to point: CGPoint) {
        animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6) {
            self.view.layoutIfNeeded()
        }
        
        view.snp.remakeConstraints { (view) in
            view.center.equalTo(point)
            view.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }
        
        animator.addAnimations ({
            view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, delayFactor: 0.15)
        
        animator.addAnimations ({
            view.transform = CGAffineTransform.identity
        }, delayFactor: 0.85)
        
        animator.startAnimation()
        
        gravityBehavior = UIGravityBehavior(items: [ball])
        
        if let gravity = gravityBehavior {
            gravity.gravityDirection = CGVector(dx: 0, dy: 1)
            self.dynamicAnimator?.addBehavior(gravity)
        }
        
        collissionBehavior = UICollisionBehavior(items: [ball])
        
        if let collission = collissionBehavior {
            collission.translatesReferenceBoundsIntoBoundary = true
            self.dynamicAnimator?.addBehavior(collission)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("No touching")
            return
        }
        
        let touchLocationInView = touch.location(in: view)
        print("Touch at: \(touchLocationInView)")
        
        if ball.frame.contains(touchLocationInView) {
            print("You touched my ball!")
            //pickUp(view: ball)
        }
        
        move(view: ball, to: touchLocationInView)
    }
    /*
    
    internal lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Oh Snap!", for: .normal)
        button.setTitle("De-Snap?", for: .selected)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    */
}
