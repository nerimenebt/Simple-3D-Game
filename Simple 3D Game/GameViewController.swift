//
//  GameViewController.swift
//  Simple 3D Game
//
//  Created by Nerimene  on 17/05/2018.
//  Copyright © 2018 Nerimene . All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    var audioPlayer:AVAudioPlayer!
    let defaults = UserDefaults.standard
    
    var scoreLabel = UILabel()
    
    var heart1 = UIImageView()
    var heart2 = UIImageView()
    var heart3 = UIImageView()
    var loseImg = UIImageView()
    
    var soundBtn = UIButton(type: .custom)
    var closeBtn = UIButton(type: .custom)
    var heartNbr = 3 {
        didSet {
            if heartNbr == 2
                {
                    heart3.image = UIImage(named: "favorite-heart-button-2")!
                }
            else if heartNbr == 1
                {
                    heart2.image = UIImage(named: "favorite-heart-button-2")!
                }
            else if heartNbr == 0
                {
                    heart1.image = UIImage(named: "favorite-heart-button-2")!
                    loseImg.isHidden = false
                }
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Your Score : \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        self.soundBtn.addTarget(self, action: #selector(GameViewController.soundAction(_:)), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(GameViewController.closeAction(_:)), for: .touchUpInside)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.replayAction(tapGestureRecognizer:)))
        loseImg.isUserInteractionEnabled = true
        loseImg.addGestureRecognizer(tapGestureRecognizer)
        
        let url = Bundle.main.url(forResource: "bgSound", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.currentTime = 0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in })
        }
        catch let error as NSError
        {
            print(error.debugDescription)
        }
        if defaults.bool(forKey: "sound")
        {
            soundBtn.setImage(UIImage(named: "mainsoundon"), for: .normal)
            audioPlayer.play()
        }
        else
        {
            soundBtn.setImage(UIImage(named: "mainsoundoff"), for: .normal)
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
    }
    
    @objc func soundAction(_ sender:UIButton!)
    {
        if defaults.bool(forKey: "sound")
        {
            defaults.set(false, forKey: "sound")
            soundBtn.setImage(UIImage(named: "mainsoundoff"), for: .normal)
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        else
        {
            defaults.set(true, forKey: "sound")
            soundBtn.setImage(UIImage(named: "mainsoundon"), for: .normal)
            audioPlayer.play()
        }
    }
    
    @objc func closeAction(_ sender:UIButton!)
    {
        exit(0)
    }
    
    @objc func replayAction(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.score = 0
        self.heartNbr = 3
        self.loseImg.isHidden = true
        heart1.image = UIImage(named: "like-2")!
        heart2.image = UIImage(named: "like-2")!
        heart3.image = UIImage(named: "like-2")!
    }
    
    @objc func initView()
    {
        gameView = (self.view as! SCNView)
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    @objc func initScene ()
    {
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
        initComposants()
    }
    
    @objc func initComposants()
    {
        soundBtn = UIButton(frame: CGRect(x: view.frame.width - 50, y: 0, width: 50, height: 50))
        soundBtn.setTitle("",for: .normal)
        soundBtn.setImage(UIImage(named: "mainsoundon"), for: .normal)
        heart1.image = UIImage(named: "like-2")!
        heart2.image = UIImage(named: "like-2")!
        heart3.image = UIImage(named: "like-2")!
        heart1.clipsToBounds = true
        heart2.clipsToBounds = true
        heart3.clipsToBounds = true
        let stackView = UIStackView(frame: CGRect(x: 20, y: 20, width: 170, height: 50))
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(heart1)
        stackView.addArrangedSubview(heart2)
        stackView.addArrangedSubview(heart3)

        loseImg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        loseImg.image = UIImage(named: "gameOver")!
        loseImg.clipsToBounds = true
        closeBtn = UIButton(frame: CGRect(x: loseImg.frame.width - 50, y: 50, width: 50, height: 50))
        closeBtn.setTitle("",for: .normal)
        closeBtn.setImage(UIImage(named: "cancel"), for: .normal)
        loseImg.addSubview(closeBtn)
        scoreLabel = UILabel(frame: CGRect(x: 20, y: 50, width: loseImg.frame.width - 60, height: 50))
        scoreLabel.textAlignment = .left
        scoreLabel.textColor = UIColor.white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 30)
        scoreLabel.text = "Your Score : " + "\(score)"
        loseImg.addSubview(scoreLabel)
        loseImg.isHidden = true
        
        view.addSubview(stackView)
        view.addSubview(soundBtn)
        view.addSubview(loseImg)
    }
    
    @objc func initCamera()
    {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y:5, z: 10)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func createTarget()
    {
        let geometry:SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        geometry.materials.first?.diffuse.contents = randomColor
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        if randomColor == UIColor.red
        {
            geometryNode.name = "enemy"
        }
        else
        {
            geometryNode.name = "friend"
        }
        gameScene.rootNode.addChildNode(geometryNode)
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if time > targetCreationTime
        {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        if let hitObject = hitList.first
        {
            let node = hitObject.node
            if node.name == "friend"
            {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.black
                self.heartNbr -= 1
                if self.score == 0
                {
                    self.score = 0
                }
                else
                {
                    self.score -= 1
                }
                self.view.vibrateAnimated()
            }
            else
            {
                node.removeFromParentNode()
                self.score += 1
            }
        }
    }
    
    @objc func cleanUp ()
    {
        for node in gameScene.rootNode.childNodes
        {
            if node.presentation.position.y < -2
            {
                node.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        }
        else
        {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension UIView {
    
    func vibrateAnimated()
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
