//
//  ViewController.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit
import SnapKit
import AudioToolbox

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    var ball: UIImageView!
    var scoreDisplay: OutlinedText!
    var hiScoreDisplay: OutlinedText!
    var button: UIButton!
    
    var animator: UIViewPropertyAnimator? = nil
    var dynamicAnimator: UIDynamicAnimator? = nil
    var snapping: UISnapBehavior?
    var falling: UIGravityBehavior?
    var colliding: UICollisionBehavior?
    
    var score = 0
    var hiScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = true
        
        setUpViews()
        
        self.button.addTarget(self, action: #selector(snapToCenter(sender:)), for: .touchUpInside)
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    // MARK: - Styling
    
    func setUpViews() {
        // MARK: - Ball styling
        
        ball = UIImageView(frame: .zero)
        ball.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ball)
        
        ball.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalTo(100)
            view.height.equalTo(100)
        }
        
        ball.image = UIImage(imageLiteralResourceName: "disco").alpha(value: 0.5)
        ball.backgroundColor = .white
        ball.layer.cornerRadius = 50
        
        // MARK: - Score styling
        
        scoreDisplay = OutlinedText(frame: .zero)
        scoreDisplay.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scoreDisplay)
        
        scoreDisplay.snp.makeConstraints { (view) in
            view.height.equalTo(100)
            view.width.equalTo(100)
            view.top.equalToSuperview()
            view.leading.equalToSuperview().offset(10)
        }
        
        scoreDisplay.text = String(score)
        scoreDisplay.textColor = .white
        scoreDisplay.font = UIFont(name: "Futura-CondensedExtraBold", size: 72)
        
        // MARK: - Button styling
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        button.snp.makeConstraints { (view) in
            view.width.equalTo(120)
            view.height.equalTo(60)
            view.trailing.equalToSuperview().inset(16)
            view.top.equalToSuperview().offset(16)
        }
        
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        
        // MARK: - HiScore styling
        
        hiScoreDisplay = OutlinedText(frame: .zero)
        hiScoreDisplay.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hiScoreDisplay)
        
        hiScoreDisplay.snp.makeConstraints { (view) in
            view.height.equalTo(100)
            view.width.equalTo(350)
            view.bottom.equalToSuperview()
            view.trailing.equalTo(self.button)
        }
        
        hiScoreDisplay.text = "High: \(hiScore)"
        hiScoreDisplay.textAlignment = .right
        hiScoreDisplay.textColor = .white
        hiScoreDisplay.font = UIFont(name: "Futura-CondensedExtraBold", size: 72)
    }
    
    // MARK: - Collission Delegate
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        print("Contact - \(identifier)")
        
        if score > hiScore {
            hiScore = score
            hiScoreDisplay.text = "High: \(hiScore)"
        }
        
        score = 0
        scoreDisplay.text = String(score)
        
    }
    
    // MARK: - Movement & Behavior
    
    internal func snapToCenter(sender: UIButton) {
        score = 0
        scoreDisplay.text = String(score)
        
        snapping = UISnapBehavior(item: ball, snapTo: self.view.center)
        self.dynamicAnimator?.addBehavior(snapping!)
    }
    
    internal func fall() {
        falling = UIGravityBehavior(items: [ball])
        
        falling?.gravityDirection = CGVector(dx: 0, dy: 0.7)
        self.dynamicAnimator?.addBehavior(falling!)
        
        colliding = UICollisionBehavior(items: [ball])
        colliding?.collisionDelegate = self
        
        if let collission = colliding {
            collission.translatesReferenceBoundsIntoBoundary = true
            self.dynamicAnimator?.addBehavior(collission)
        }
        
        colliding?.addBoundary(withIdentifier: "bottom" as NSCopying, from: CGPoint(x: view.frame.minX, y: view.frame.maxY), to: CGPoint(x: view.frame.maxX, y: view.frame.maxY))
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
            view.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        animator?.addAnimations {
            view.transform = CGAffineTransform(rotationAngle: 2)
        }
        
        animator?.startAnimation()
        
        fall()
    }
    
    internal func pickUp(view: UIView) {
        animator = UIViewPropertyAnimator(duration: 1, curve: .easeIn, animations: {
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        
        SystemSoundID.playFileNamed(fileName: "beep", withExtenstion: "mp3")
        
        let randomHue = CGFloat(arc4random_uniform(100)) * 0.01
        let randomSaturation = CGFloat(arc4random_uniform(100)) * 0.01
        let randomBrightness = CGFloat(arc4random_uniform(100)) * 0.01
        //let color = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let color = UIColor(hue: randomHue, saturation: randomSaturation, brightness: randomBrightness, alpha: 1.0)
        
        view.backgroundColor = color
        button.backgroundColor = color
        
        if randomBrightness < 0.49 {
            button.setTitleColor(.white, for: .normal)
        } else {
            button.setTitleColor(.black, for: .normal)
        }
        
        scoreDisplay.textColor = color
        hiScoreDisplay.textColor = color
        score += 1
        scoreDisplay.text = String(score)
        
        animator?.startAnimation()
    }
    
    internal func putDown(view: UIView) {
        animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn, animations: {
            view.transform = CGAffineTransform.identity
        })
        
        animator?.startAnimation()
    }
    
    // MARK: - Observing touches
    
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
}
