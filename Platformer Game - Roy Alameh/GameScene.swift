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
    var graphs = [String : GKGraph]()
    
    var moveRight = false
    var moveLeft = false
    var jumpNum = 0
    var maxJumps = 2
    
    var player : SKSpriteNode!
    var ground : SKSpriteNode!
    var coin : SKSpriteNode!
    var enemy1 : SKSpriteNode!
    
    var jumpSpeed = 600
    var runMaxSpeed = 325
    var runAcceleration = 1000
    
    override func sceneDidLoad() {
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        player = self.childNode(withName: "player") as? SKSpriteNode
        ground = self.childNode(withName: "ground") as? SKSpriteNode
        player.physicsBody?.categoryBitMask = 1
        ground.physicsBody?.categoryBitMask = 2
        player.physicsBody?.contactTestBitMask = 2
        ground.physicsBody?.contactTestBitMask = player.physicsBody?.contactTestBitMask ?? 0
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
        print("test")
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
        
        print(player != nil)
        print(ground != nil)
        if player != nil && ground != nil {
            jumpNum = 0
        }
    }
}
