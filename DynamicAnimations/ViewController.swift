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

class ViewController: UIViewController {
    var ball: UIImageView!
    var scoreDisplay: OutlinedText!
    var animator: UIViewPropertyAnimator? = nil
    var dynamicAnimator: UIDynamicAnimator? = nil
    var snapBehavior: UISnapBehavior?
    var gravityBehavior: UIGravityBehavior?
    var collissionBehavior: UICollisionBehavior?
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = true
        
        ball = UIImageView(frame: .zero)
        ball.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ball)
        ball.backgroundColor = .white
        ball.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalTo(100)
            view.height.equalTo(100)
        }
        ball.image = UIImage(imageLiteralResourceName: "disco").alpha(value: 0.5)
        ball.layer.cornerRadius = 50
        
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
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: 120).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0).isActive = true
        
        button.isEnabled = true
        self.button.addTarget(self, action: #selector(snapToCenter(sender:)), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func snapToCenter(sender: UIButton) {
        score = 0
        scoreDisplay.text = String(score)
        
        snapBehavior = UISnapBehavior(item: ball, snapTo: self.view.center)
        self.dynamicAnimator?.addBehavior(snapBehavior!)
    }
    
    internal func fall() {
        gravityBehavior = UIGravityBehavior(items: [ball])
        
        gravityBehavior?.gravityDirection = CGVector(dx: 0, dy: 0.7)
        self.dynamicAnimator?.addBehavior(gravityBehavior!)
        
        collissionBehavior = UICollisionBehavior(items: [ball])
        
        if let collission = collissionBehavior {
            collission.translatesReferenceBoundsIntoBoundary = true
            self.dynamicAnimator?.addBehavior(collission)
        }
        
        let hitBottom = CGPoint(x: ball.frame.midX, y: view.frame.maxY - 50)
        
        if ball.frame.contains(hitBottom) {
            score = 0
            scoreDisplay.text = String(score)
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
        
        if randomBrightness < 0.3 {
            button.setTitleColor(.white, for: .normal)
        } else {
            button.setTitleColor(.black, for: .normal)
        }
        
        self.scoreDisplay.textColor = color
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
    
    internal lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
}

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


// from http://stackoverflow.com/questions/24043904/creating-and-playing-a-sound-in-swift
extension SystemSoundID {
    static func playFileNamed(fileName: String, withExtenstion fileExtension: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
}

// sound effect courtesy of https://www.partnersinrhyme.com/soundfx/PUBLIC-DOMAIN-SOUNDS/misc_sounds/beep_beep-spac_wav.shtml
