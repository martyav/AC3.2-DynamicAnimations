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
    var ball: UIView!
    var animator: UIViewPropertyAnimator? = nil
    var dynamicAnimator: UIDynamicAnimator? = nil
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
    
    internal func fall() {
        gravityBehavior = UIGravityBehavior(items: [ball])
        
        gravityBehavior?.gravityDirection = CGVector(dx: 0, dy: 1)
        self.dynamicAnimator?.addBehavior(gravityBehavior!)
        
        collissionBehavior = UICollisionBehavior(items: [ball])
        
        if let collission = collissionBehavior {
            collission.translatesReferenceBoundsIntoBoundary = true
            self.dynamicAnimator?.addBehavior(collission)
        }
    }
    
    internal func move(view: UIView, to point: CGPoint) {
        if let dynamic = self.dynamicAnimator {
            dynamic.removeAllBehaviors()
        }
        
        animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6) {
            self.view.layoutIfNeeded()
        }
        
        view.snp.remakeConstraints { (view) in
            view.center.equalTo(point)
            view.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }
        
        animator?.startAnimation()
        
        fall()
    }
    
    internal func pickUp(view: UIView) {
        self.animator = UIViewPropertyAnimator(duration: 1, curve: .easeIn, animations: {
            let randomRed = CGFloat(arc4random_uniform(100)) * 0.01
            let randomGreen = CGFloat(arc4random_uniform(100)) * 0.01
            let randomBlue = CGFloat(arc4random_uniform(100)) * 0.01
            view.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        
        animator?.startAnimation()
    }
    
    internal func putDown(view: UIView) {
        animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn, animations: {
            view.transform = CGAffineTransform.identity
        })
        
        animator?.startAnimation()
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
            pickUp(view: ball)
        }
        
        move(view: ball, to: touchLocationInView)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        putDown(view: ball)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        move(view: ball, to: touch.location(in: view))
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
