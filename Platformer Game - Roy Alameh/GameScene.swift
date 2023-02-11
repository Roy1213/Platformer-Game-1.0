//
//  GameScene.swift
//  Platformer Game - Roy Alameh
//
//  Created by Roy Alameh on 2/9/23.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs   = [String : GKGraph]()
    
    var moveRight = false
    var moveLeft  = false
    var jumpNum   = 0
    var maxJumps  = 2
    
    var player : SKSpriteNode!
    var ground : SKSpriteNode!
    var coin   : SKSpriteNode!
    var enemy1 : SKSpriteNode!
    
    let playerCategory : UInt32 = 0x1 << 0
    let groundCategory : UInt32 = 0x1 << 1
    let coinCategory   : UInt32 = 0x1 << 2
    let enemy1Category : UInt32 = 0x1 << 3
    
    var jumpSpeed       = 600
    var runMaxSpeed     = 325
    var runAcceleration = 1000
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        player = self.childNode(withName: "player") as? SKSpriteNode
        ground = self.childNode(withName: "ground") as? SKSpriteNode
        if let enemy1 = self.childNode(withName: "enemy1") as? SKSpriteNode {
            self.enemy1 = enemy1
        }
        else {
            print("error")
            return }
        
        player.physicsBody?.categoryBitMask    = playerCategory
        player.physicsBody?.contactTestBitMask = groundCategory | enemy1Category
        ground.physicsBody?.categoryBitMask    = groundCategory
        ground.physicsBody?.contactTestBitMask = playerCategory
        enemy1.physicsBody?.categoryBitMask    = enemy1Category
        enemy1.physicsBody?.contactTestBitMask = playerCategory
    }
    
    
   
    override func update(_ currentTime: TimeInterval) {
        if (moveRight || moveLeft) && abs(self.childNode(withName: "player")?.physicsBody?.velocity.dx ?? 0) < CGFloat(Double(runMaxSpeed)) {
            var multiplier = -1
            if moveRight {
                multiplier = 1
            }
            self.childNode(withName: "player")?.physicsBody?.applyForce(CGVector(dx: multiplier * runAcceleration, dy: 0))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var player : SKSpriteNode!
        var ground : SKSpriteNode!
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2 {
            player = contact.bodyA.node as? SKSpriteNode
            ground = contact.bodyB.node as? SKSpriteNode
        }
        else if contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1 {
            player = contact.bodyB.node as? SKSpriteNode
            ground = contact.bodyA.node as? SKSpriteNode
        }
        if player != nil && ground != nil {
            jumpNum = 0
        }
    }
}
