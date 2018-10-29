//
//  GameScene.swift
//  Nails
//
//  Created by Hunter Bashaw on 10/6/18.
//  Copyright © 2018 Blivet. All rights reserved.
//

import SpriteKit
import GameplayKit

func random(_ n:Int) -> Int
{
    return Int(arc4random_uniform(UInt32(n)))
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let background = SKSpriteNode(imageNamed: "stars")
    let menuLabel1 = SKLabelNode(text: "Nails")
    let menuLabel2 = SKLabelNode(text: "Tap to begin the invaition")
    var menu: Bool = true
    let pathToBattleWav = Bundle.main.path(forResource: "battle.wav", ofType: nil)!
    let pathToBlopWav = Bundle.main.path(forResource: "blop.wav", ofType: nil)!
    let ship = SKSpriteNode(imageNamed: "newship")
    let monkey = SKSpriteNode(imageNamed: "monkeyblow")
    var score = SKLabelNode(text: "0")
    var health = SKLabelNode(text: "10")
    var numScore = 0
    var numHealth = 10
    var numOfBalloons = 0
    var blopSound: SKAudioNode? 
    
    override func didMove(to view: SKView) {
        //Probs not nessisary, but makes me feel good
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //Set background
        background.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        background.scale(to: CGSize(width: view.frame.width, height: view.frame.height))
        background.zPosition = 0
        addChild(background)
        
        //Menu labels setup
        menuLabel1.position = CGPoint(x: view.frame.width / 2, y: (view.frame.height / 2) + (view.frame.height / 8))
        menuLabel1.fontSize = 60
        menuLabel1.zPosition = 7
        addChild(menuLabel1)
        menuLabel2.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        menuLabel2.fontSize = 60
        menuLabel2.zPosition = 6
        addChild(menuLabel2)
        
        //Start edgy battle musioc
        let backMusic = SKAudioNode(url: URL(fileURLWithPath: pathToBattleWav))
        addChild(backMusic)
        
        //Setup cartoony blop noise
        let blopMusic = SKAudioNode(url: URL(fileURLWithPath: pathToBlopWav))
        blopMusic.autoplayLooped = false
        blopSound = blopMusic
        blopSound?.run(SKAction.stop())
        addChild(blopSound!)
        
        //Setup ship and sea
        ship.name = "ship"
        ship.anchorPoint = CGPoint(x: ship.anchorPoint.x, y: 0.0)
        ship.position = CGPoint(x: view.frame.width / 2, y: 0.0)
        ship.scale(to: CGSize(width: view.frame.width, height: view.frame.height / 2))
        ship.zPosition = 1
        addChild(ship)
        
        //Setup Captain Ted
        monkey.name = "monkey"
        monkey.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(20))
        monkey.physicsBody?.isDynamic = false
        monkey.physicsBody?.categoryBitMask = 0b01
        monkey.physicsBody?.collisionBitMask = 0b01
        monkey.physicsBody?.contactTestBitMask = 0b01
        monkey.position = CGPoint(x: (view.frame.width / 2) - (view.frame.width / 32), y: (view.frame.height / 4) + (view.frame.height / 16))
        monkey.scale(to: CGSize(width: view.frame.width / 16, height: view.frame.height / 8))
        monkey.zPosition = 2
        addChild(monkey)
        
        //Setup score counter
        score.zPosition = 5
        score.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - (view.frame.height / 8))
        score.fontSize = CGFloat(50)
        addChild(score)
        
        //Setup health counter
        health.zPosition = 5
        health.position = CGPoint(x: view.frame.width / 4, y: view.frame.height - (view.frame.height / 8))
        health.fontSize = CGFloat(50)
        addChild(health)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        //check for menu scene
        if menu { // Can I avoid this check every time? Maybe...
            menu = false
            menuLabel1.run(SKAction.fadeOut(withDuration: 0.5), completion: {() -> Void in self.menuLabel1.removeFromParent();})
            menuLabel2.run(SKAction.fadeOut(withDuration: 0.5), completion: {() -> Void in self.menuLabel2.removeFromParent();})
        }
        //Geomentry to send nail to the edge of the screen
        let m = (pos.y - monkey.position.y) / (pos.x - monkey.position.x)
        let xCoord = ((view!.frame.height - monkey.position.y) / m) + monkey.position.x
        
        //Rotate Monkey and nail
        let angle = atan2(pos.y - monkey.position.y, pos.x - monkey.position.x)
        let rotation = SKAction.rotate(toAngle: angle, duration: 0.1)
        monkey.run(rotation)
        
        //fire nail
        let nail = SKSpriteNode(imageNamed: "nail")
        nail.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(view!.frame.width / 8))
        nail.physicsBody?.mass = 10
        nail.physicsBody?.isDynamic = true
        nail.physicsBody?.affectedByGravity = false
        nail.physicsBody?.categoryBitMask = 0b01
        nail.physicsBody?.collisionBitMask = 0b01
        nail.physicsBody?.contactTestBitMask = 0b01
        nail.name = "nail"
        nail.position = monkey.position
        nail.zPosition = 3
        nail.scale(to: CGSize(width: view!.frame.width / 16, height: view!.frame.height / 16))
        nail.run(rotation)
        
        let fireAni = SKAction.move(to: CGPoint(x: xCoord, y: view!.frame.height), duration: 0.5)
        nail.run(fireAni, completion: {() -> Void in nail.removeFromParent()}) //Freaking love completion closures :P
        addChild(nail)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func checkBallons(){
        if numOfBalloons < ((numScore / 50) + 2) { // Progressively make harder (or easier depending on if you've looked at the shitty.physics body code)
            let balloon = SKSpriteNode(imageNamed: "balloon")
            balloon.position = CGPoint(x: CGFloat(random(Int(view!.frame.width))), y: view!.frame.height)
            balloon.physicsBody = SKPhysicsBody(circleOfRadius: view!.frame.width / 6)
            balloon.physicsBody?.mass = 1000 //Mitigates bug where nail moves balloon out of way instead of colliding
            balloon.physicsBody?.isDynamic = true
            balloon.physicsBody?.affectedByGravity = false
            balloon.physicsBody?.categoryBitMask = 0b01
            balloon.physicsBody?.collisionBitMask = 0b01
            balloon.physicsBody?.contactTestBitMask = 0b01
            balloon.name = "balloon"
            numOfBalloons += 1
            balloon.zPosition = 4
            balloon.scale(to: CGSize(width: (view!.frame.width / 8), height: (view!.frame.height / 8)))
            let ballAni = SKAction.move(to: monkey.position, duration: 2.0)
            balloon.run(ballAni)
            addChild(balloon)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node!.name! == "monkey" && contact.bodyB.node!.name! == "balloon" {
            contact.bodyB.node!.removeFromParent()
            numOfBalloons -= 1
            numHealth -= 1
        } else if contact.bodyA.node!.name! == "nail" && contact.bodyB.node!.name! == "ballon" {
            contact.bodyB.node!.removeFromParent()
            contact.bodyA.node!.removeFromParent()
            numOfBalloons -= 1
            numScore += 1
            blopSound?.run(SKAction.play())
        } else if contact.bodyA.node!.name! == "balloon" && contact.bodyB.node!.name! == "nail" {
            contact.bodyB.node!.removeFromParent()
            contact.bodyA.node!.removeFromParent()
            numOfBalloons -= 1
            numScore += 1
            blopSound?.run(SKAction.play())
        } else if contact.bodyA.node!.name! == "balloon" && contact.bodyB.node!.name! == "monkey" {
            contact.bodyA.node!.removeFromParent()
            numOfBalloons -= 1
            numScore -= 1
        }
        if numHealth < 1 {
            reset()
        } else {
            checkBallons()
            score.text = String(numScore)
            health.text = String(numHealth)
        }
    }
    
    func reset() {
        numScore = 0
        numHealth = 10
        numOfBalloons = 0
        for ent in self.children {
            if ent.name == "balloon" || ent.name == "nail" {
                ent.removeFromParent()
            }
        }
        menu = true
        menuLabel1.text = "You Ded."
        menuLabel1.run(SKAction.fadeIn(withDuration: 0.5))
        addChild(menuLabel1)
        menuLabel2.text = "Tap to restart invation"
        menuLabel2.run(SKAction.fadeIn(withDuration: 0.5))
        addChild(menuLabel2)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        //heh
    }
}
