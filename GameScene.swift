//
//  GameScene.swift
//  InfiniteJourney
//
//  Created by ADB on 1/31/17.
//  Copyright © 2017 ADB. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let speedChangeFactor: CGFloat = 1.5
    var groundScrollSpeed: CGFloat = 900
    var mountainScrollSpeed: CGFloat = 300
    var cactusScrollSpeed: CGFloat = 450
    var cloudScrollSpeed: CGFloat = 100
    let staticDelta: TimeInterval = 1.0/60.0
    var scrollLayerFast: SKNode!
    var scrollLayerMediumFast: SKNode!
    var scrollLayerMedium: SKNode!
    var scrollLayerSlow: SKNode!
    var scoreLabel: SKLabelNode!
    var onesDigit: CGFloat = 0
    var tensDigit: CGFloat = 0
    var cowboy: Cowboy!
    var cowboyYPosition: CGFloat!
    var animationStartTime: TimeInterval = 0.0
    var meterStartTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    var animationCounter: Int = 0
    var points = 0
    var wind: SKSpriteNode!
    var shop: MSButtonNode!
    var blurBackground: SKSpriteNode!
    var shopScreen: SKSpriteNode!
    var backToGame: MSButtonNode!
    var button1: MSButtonNode!
    var button2: MSButtonNode!
    var hotdog: SKSpriteNode!
    var runningTime = 0.0
    var energy: SKSpriteNode!
    var spinningCoin: SKSpriteNode!
    var donateButton: MSButtonNode!
    var isGamePaused = false
    var nodeGenerationTimer: Timer!
    var meterValue: SKNode!
    var zero: SKSpriteNode!
    var one: SKSpriteNode!
    var two: SKSpriteNode!
    var three: SKSpriteNode!
    var four: SKSpriteNode!
    var five: SKSpriteNode!
    var six: SKSpriteNode!
    var seven: SKSpriteNode!
    var eight: SKSpriteNode!
    var nine: SKSpriteNode!
    var meter: SKSpriteNode!
    var levelCount: CGFloat = 0
    var distance: [Int] = Levels().getLevelDistances()
    var levelNum: Int = 0

    override func didMove(to view: SKView) {

        scrollLayerFast = self.childNode(withName: "scrollLayerFast")
        scrollLayerMediumFast = self.childNode(withName: "scrollLayerMediumFast")
        scrollLayerMedium = self.childNode(withName: "scrollLayerMedium")
        scrollLayerSlow = self.childNode(withName: "scrollLayerSlow")
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        cowboy = self.childNode(withName: "cowboy") as! Cowboy
        wind = self.childNode(withName: "Wind") as! SKSpriteNode
        shop = self.childNode(withName: "shop") as! MSButtonNode
        blurBackground = self.childNode(withName: "blurBackground") as! SKSpriteNode
        shopScreen = self.childNode(withName:"shopScreen") as! SKSpriteNode
        backToGame = self.childNode(withName: "backToGame") as! MSButtonNode
        cowboyYPosition = CGFloat(cowboy.position.y)
        scoreLabel.text = String(points) + " m"
        button1 = self.childNode(withName: "button1") as! MSButtonNode
        button2 = self.childNode(withName: "button2") as! MSButtonNode
        hotdog = self.childNode(withName: "hotdog") as! SKSpriteNode
        energy = self.childNode(withName: "energy") as! SKSpriteNode
        meterValue = self.childNode(withName: "meterValue")
        
        /*zero = self.childNode(withName: "zero") as! SKSpriteNode
        one = self.childNode(withName: "one") as! SKSpriteNode
        two = self.childNode(withName: "two") as! SKSpriteNode
        three = self.childNode(withName: "three") as! SKSpriteNode
        four = self.childNode(withName: "four") as! SKSpriteNode
        five = self.childNode(withName: "five") as! SKSpriteNode
        six = self.childNode(withName: "six") as! SKSpriteNode
        seven = self.childNode(withName: "seven") as! SKSpriteNode
        eight = self.childNode(withName: "eight") as! SKSpriteNode
        nine = self.childNode(withName: "nine") as! SKSpriteNode
        meter = self.childNode(withName: "meter") as! SKSpriteNode*/
        
        donateButton = self.shopScreen.childNode(withName: "donateButton") as! MSButtonNode
        nodeGenerationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(GameScene.nodeGeneration), userInfo: nil, repeats: true)

        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        shop.selectedHandler = {
            self.isGamePaused = true
            self.shopScreen.run(SKAction(named: "slideDown")!)
            self.blurBackground.position = CGPoint(x: 0, y:0)
            self.backToGame.run(SKAction(named: "backButtonDown")!)
            self.shop.position = CGPoint(x: 500, y: 540)
        }
        
        backToGame.selectedHandler = {
            self.isGamePaused = false
            self.shopScreen.run(SKAction(named: "slideUp")!)
            self.blurBackground.position = CGPoint(x: 1000, y: 0)
            self.backToGame.run(SKAction(named: "backButtonUp")!)
            self.shop.position = CGPoint(x: 240, y: 540)
        }
        
        button1.selectedHandler = {
            self.hotdog.run(SKAction(named: "Hotdog")!)
            self.startRunning(x: 2.8)
            self.cowboy.characterState = .Idle
        }
        button2.selectedHandler = {
            self.energy.run(SKAction(named: "Energy")!)
        }
        donateButton.selectedHandler = {
        }
    }
    
    func scrollWorld()  {
        /* Scroll World */
        scrollLayerFast.position.x -= groundScrollSpeed * CGFloat(1.0 / 60.0)
        let ground1 = scrollLayerFast.children[0] as! SKSpriteNode
        let ground2 = scrollLayerFast.children[1] as! SKSpriteNode
        /* Get ground node position, convert node position to scene space */
        var groundPosition = scrollLayerFast.convert(ground1.position, to: self)
        /* Check if ground sprite has left the scene */
        if groundPosition.x <= -ground1.size.width {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground1.size.width + scrollLayerFast.convert(ground2.position, to: self).x, y: groundPosition.y)
            /* Convert new node position back to scroll layer space */
            ground1.position = self.convert(newPosition, to: scrollLayerFast)
        }
        groundPosition = scrollLayerFast.convert(ground2.position, to: self)
        /* Check if ground sprite has left the scene */
        if groundPosition.x <= -ground2.size.width {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground2.size.width + scrollLayerFast.convert(ground1.position, to: self).x, y: groundPosition.y)
            /* Convert new node position back to scroll layer space */
            ground2.position = self.convert(newPosition, to: scrollLayerFast)
        }
        scrollLayerMediumFast.position.x -= mountainScrollSpeed * CGFloat(1.0 / 60.0)
        let mountain1 = scrollLayerMediumFast.children[0] as! SKSpriteNode
        let mountain2 = scrollLayerMediumFast.children[1] as! SKSpriteNode
        /* Get ground node position, convert node position to scene space */
        var mountainPosition = scrollLayerMediumFast.convert(mountain1.position, to: self)
        /* Check if ground sprite has left the scene */
        if mountainPosition.x <= -mountain1.size.width {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: mountain1.size.width + scrollLayerMediumFast.convert(mountain2.position, to: self).x, y: mountainPosition.y)
            /* Convert new node position back to scroll layer space */
            mountain1.position = self.convert(newPosition, to: scrollLayerMediumFast)
        }
        mountainPosition = scrollLayerMediumFast.convert(mountain2.position, to: self)
        /* Check if ground sprite has left the scene */
        if mountainPosition.x <= -mountain2.size.width {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: mountain2.size.width + scrollLayerMediumFast.convert(mountain1.position, to: self).x, y: mountainPosition.y)
            /* Convert new node position back to scroll layer space */
            mountain2.position = self.convert(newPosition, to: scrollLayerMediumFast)
        }
        scrollLayerMedium.position.x -= cactusScrollSpeed * CGFloat(1.0 / 60.0)
        let cactus1 = scrollLayerMedium.children[0] as! SKSpriteNode
        let cactus2 = scrollLayerMedium.children[1] as! SKSpriteNode
        /* Get ground node position, convert node position to scene space */
        var cactusPosition = scrollLayerMedium.convert(cactus1.position, to: self)
        /* Check if ground sprite has left the scene */
        if cactusPosition.x <= -ground1.size.width * 1.5 {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground1.size.width * 0.5, y: cactusPosition.y)
            /* Convert new node position back to scroll layer space */
            cactus1.position = self.convert(newPosition, to: scrollLayerMedium)
        }
        cactusPosition = scrollLayerMedium.convert(cactus2.position, to: self)
        /* Check if ground sprite has left the scene */
        if cactusPosition.x <= -ground2.size.width * 1.5 {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground2.size.width * 0.5, y: cactusPosition.y)
            /* Convert new node position back to scroll layer space */
            cactus2.position = self.convert(newPosition, to: scrollLayerMedium)
        }
        scrollLayerSlow.position.x -= cloudScrollSpeed * CGFloat(1.0 / 60.0)
        let cloud1 = scrollLayerSlow.children[0] as! SKSpriteNode
        let cloud2 = scrollLayerSlow.children[1] as! SKSpriteNode
        /* Get ground node position, convert node position to scene space */
        var cloudPosition = scrollLayerSlow.convert(cloud1.position, to: self)
        /* Check if ground sprite has left the scene */
        if cloudPosition.x <= -ground1.size.width * 1.5 {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground1.size.width * 0.65, y: cloudPosition.y)
            /* Convert new node position back to scroll layer space */
            cloud1.position = self.convert(newPosition, to: scrollLayerSlow)
        }
        cloudPosition = scrollLayerSlow.convert(cloud2.position, to: self)
        /* Check if ground sprite has left the scene */
        if cloudPosition.x <= -ground2.size.width * 1.5 {
            /* Reposition ground sprite to the second starting position */
            let newPosition = CGPoint(x: ground2.size.width * 0.65, y: cloudPosition.y)
            /* Convert new node position back to scroll layer space */
            cloud2.position = self.convert(newPosition, to: scrollLayerSlow)
        }
    }

    func nodeGeneration() {
        if let coin = spinningCoin  {
            coin.removeFromParent()
        }
        spinningCoin = self.childNode(withName: "spinningCoin")!.copy() as! SKSpriteNode
        self.addChild(spinningCoin)
        spinningCoin.run(SKAction(named: "spinningCoin")!)
        let randomX = CGFloat(Int(arc4random_uniform(1)+1))
        spinningCoin.position = CGPoint(x: frame.size.width+100, y: -frame.size.height/2 + 170)
        let moveAction = SKAction.moveBy(x: -1*randomX, y: 0, duration: 0.005)
        let repeatMoveAction = SKAction.repeatForever(moveAction)
        spinningCoin.run(repeatMoveAction)
        if (spinningCoin.position.x<frame.size.width)
        {
            spinningCoin.removeFromParent()
        }
    }

    func changeSpeed(factor: CGFloat)   {
        groundScrollSpeed *= factor
        mountainScrollSpeed *= factor
        cactusScrollSpeed *= factor
        cloudScrollSpeed *= factor
    }
    
    func returnSpeed()  {
        groundScrollSpeed = 900
        mountainScrollSpeed = 300
        cactusScrollSpeed = 450
        cloudScrollSpeed = 100
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if (!self.isGamePaused)  {
            let n = self.childNode(withName: "Wind")!.copy() as! SKSpriteNode
            n.position = pos
            n.run(SKAction.sequence([SKAction(named: "Wind")!, SKAction.removeFromParent()]))
            n.zPosition = 2
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func startRunning(x: Double) {
        changeSpeed(factor: 2.0)
        runningTime = x
        points += cowboy.clickPoint
        animationCounter = 0
        animationStartTime = Date().timeIntervalSinceReferenceDate
        
        if (cowboy.characterState != .Running) {
            cowboy.removeAction(forKey: "Idle")
            cowboy.run(SKAction(named: "Run")!)
            cowboy.characterState = .Running
        }
    }
    
    func swipedRight(_ gesture: UIGestureRecognizer) {
        startRunning(x: 3.0)
    }
    
    func swipedLeft(_ gesture: UIGestureRecognizer) {
        print("swiped left")
    }
    
    func swipedDown(_ gesture: UIGestureRecognizer) {
        runningTime = 1
        animationCounter = 0
        animationStartTime = Date().timeIntervalSinceReferenceDate
        if (cowboy.characterState != .Sliding) {
            cowboy.removeAction(forKey: "Idle")
            cowboy.run(SKAction(named: "Slide")!)
            cowboy.characterState = .Sliding
        }
    }
    
    func shopButtonPressed() {
        self.addChild(scrollLayerFast)
        self.addChild(scrollLayerSlow)
        self.addChild(scrollLayerMedium)
        self.addChild(scrollLayerMediumFast)
        self.addChild(scoreLabel)
        self.addChild(cowboy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches    {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (!self.isGamePaused)    {
            
            // Update score label
            
            /*for i in String(points).characters.indices {
                switch String(points)[i]    {
                    case "0":
                        let n = zero.copy() as! SKSpriteNode
                        print("0")
                    case "1":
                        print("1")
                    case "2":
                        print("2")
                    case "3":
                        print("3")
                    default:
                        print("adb")
                }
            }*/
            scoreLabel.text = String(points) + " m"
            /*if (Int(scoreLabel.text!)! >= distance[levelNum])
            {
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill

                    // Present the scene
                    view?.presentScene(scene)
                }
            }*/
            
            // Assign current speed
            switch cowboy.characterState    {
            case .Idle:
                cowboy.currentSpeed = cowboy.idleSpeed
            case .Running:
                cowboy.currentSpeed = cowboy.runningSpeed
            case .Sliding:
                cowboy.currentSpeed = cowboy.slidingSpeed
            }
            
            let currentTime = Date().timeIntervalSinceReferenceDate
            
            if (cowboy.characterState == .Running) {
                cowboy.position.y = cowboyYPosition! - 15.0
            }
            // Check if meter needs to be added
            if (currentTime - meterStartTime >= 1.0 / Double(cowboy.currentSpeed))  {
                points += Int(floor((currentTime - meterStartTime) * Double(cowboy.currentSpeed)))
                meterStartTime = currentTime
            }
            // Check if animation needs to be removed
            if (currentTime - animationStartTime >= runningTime) {
                animationCounter += 1
                cowboy.position.y = cowboyYPosition
                if (animationCounter == 1)  {
                    cowboy.characterState = .Idle
                    returnSpeed()
                    switch cowboy.characterState    {
                    case .Running:
                        cowboy.removeAction(forKey: "Run")
                        cowboy.run(SKAction(named: "Idle")!)
                    case .Sliding:
                        cowboy.removeAction(forKey: "Slide")
                        cowboy.run(SKAction(named: "Idle")!)
                    default:
                        cowboy.run(SKAction(named: "Idle")!)
                    }
                }
            }   else    {
                cowboy.position.y = cowboyYPosition! - 15.0
            }
            scrollWorld()
            // Called before each frame is rendered
        }
    }
}
