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
    var color = UIColor.black
    var backgroundImage: UIImageView!
    
    var ball: UIImageView!
    var scoreDisplay: OutlinedText!
    var hiScoreDisplay: OutlinedText!
    var button: UIButton!
    
    var animator: UIViewPropertyAnimator? = nil
    var dynamicAnimator: UIDynamicAnimator? = nil
    var snapping: UISnapBehavior?
    var falling: UIGravityBehavior?
    var colliding: UICollisionBehavior?
    var dynamicPhysics: UIDynamicItemBehavior!
    
    var score = 0
    var hiScore = 0
    
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let hiScoreStored = prefs.string(forKey: "hiScoreStored") {
            print("The user has a high score defined: " + hiScoreStored)
            hiScore = Int(hiScoreStored)!
        } else {
         //   Nothing stored in NSUserDefaults yet. Set a value.
            prefs.setValue(hiScore, forKey: "hiScoreStored")
        }
        
        self.view.backgroundColor = color
        self.view.isUserInteractionEnabled = true
        
        setUpViews()
        
        self.button.addTarget(self, action: #selector(snapToCenter(sender:)), for: .touchUpInside)
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    // MARK: - Styling
    
    func setUpViews() {
        // BG image
        
        backgroundImage = UIImageView(frame: .zero)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundImage)
        
        backgroundImage.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalToSuperview()
        }
        
        backgroundImage.image = UIImage(imageLiteralResourceName: "cat").alpha(value: 0.1)
        backgroundImage.backgroundColor = color
        
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
            view.width.equalTo(200)
            view.top.equalToSuperview()
            view.leading.equalToSuperview().offset(10)
        }
        
        scoreDisplay.text = String(score)
        scoreDisplay.textColor = .white
        scoreDisplay.font = UIFont(name: "DS-Digital-Bold", size: 72)
        
        // MARK: - Button styling
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        button.snp.makeConstraints { (view) in
            view.width.equalTo(100)
            view.height.equalTo(50)
            view.trailing.equalToSuperview().inset(16)
            view.centerY.equalTo(scoreDisplay)
        }
        
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
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
        hiScoreDisplay.font = UIFont(name: "DS-Digital-Bold", size: 72)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // MARK: - Collission Delegate
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        print("Contact - \(identifier)")
        
        // this only works because bottom is the only boundary with an identifier...if we add more boundaries with identifiers, we'll have to eff around with this & NSCopying
        if identifier != nil {
            if score > hiScore {
                hiScore = score
                prefs.setValue("\(hiScore)", forKey: "hiScoreStored")
                hiScoreDisplay.text = "High: \(hiScore)"
            }
            
            score = 0
            scoreDisplay.text = String(score)
        }
    }
    
    // MARK: - Movement & Behavior
    
    internal func snapToCenter(sender: UIButton) {
        score = 0
        scoreDisplay.text = String(score)
        
        if let dynamic = self.dynamicAnimator {
            dynamic.removeAllBehaviors()
        }
        
        snapping = UISnapBehavior(item: ball, snapTo: self.view.center)
        self.dynamicAnimator?.addBehavior(snapping!)
    }
    
    internal func fall() {
        if let dynamic = self.dynamicAnimator {
            dynamic.removeAllBehaviors()
        }
        
        falling = UIGravityBehavior(items: [ball])
        falling?.gravityDirection = CGVector(dx: 0, dy: 1.5)
        self.dynamicAnimator?.addBehavior(falling!)
        
        colliding = UICollisionBehavior(items: [ball])
        colliding?.collisionDelegate = self
        
        if let collission = colliding {
            collission.translatesReferenceBoundsIntoBoundary = true
            self.dynamicAnimator?.addBehavior(collission)
        }
        
        colliding?.addBoundary(withIdentifier: "bottom" as NSCopying, from: CGPoint(x: view.frame.minX, y: view.frame.maxY), to: CGPoint(x: view.frame.maxX, y: view.frame.maxY))
        
        self.dynamicPhysics = UIDynamicItemBehavior(items: [ball])
        dynamicPhysics.allowsRotation = true
        dynamicPhysics.elasticity = 0.9
        dynamicPhysics.addAngularVelocity(7.0, for: ball)
        dynamicAnimator?.addBehavior(dynamicPhysics)
    }
    
    internal func move(view: UIView, to point: CGPoint) {
        if let dynamic = self.dynamicAnimator {
            dynamic.removeAllBehaviors()
        }
        
        animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.6) {
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
            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        
        SystemSoundID.playFileNamed(fileName: "beep", withExtenstion: "mp3")
        
        let randomHue = CGFloat(arc4random_uniform(100)) * 0.01
        let randomSaturation = CGFloat(arc4random_uniform(50)) * 0.01
        let randomBrightness = (CGFloat(arc4random_uniform(50)) + 50.0) * 0.01
        color = UIColor(hue: randomHue, saturation: randomSaturation, brightness: randomBrightness, alpha: 1.0)
        
        button.backgroundColor = color
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
            
            var randomPush = CGFloat(arc4random_uniform(75))
            let leftOrRight = CGFloat(arc4random_uniform(2))
            
            if leftOrRight == 1 {
                randomPush *= -1
            }
            
            move(view: ball, to: CGPoint(x: touchLocationInView.x + randomPush, y: touchLocationInView.y - 100 + randomPush))
            
            animator = UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
                self.backgroundImage.backgroundColor = self.color
            }
            
            animator?.startAnimation()
            
            backgroundImage.backgroundColor = .black
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        putDown(view: ball)
        fall()
    }
}
