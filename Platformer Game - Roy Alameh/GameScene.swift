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
    
    var player : SKShapeNode!
    var cam : SKCameraNode!
//    var ground : SKSpriteNode!
//    var coin   : SKSpriteNode!
//    var enemy1 : SKSpriteNode!
    
    let playerCategory : UInt32 = 0x1 << 0
    let groundCategory : UInt32 = 0x1 << 1
    let coinCategory   : UInt32 = 0x1 << 2
    let enemy1Category : UInt32 = 0x1 << 3
    let enemy2Category : UInt32 = 0x1 << 4
    let enemy3Category : UInt32 = 0x1 << 5
    
    var jumpSpeed       = 600
    var runMaxSpeed     = 325
    var runAcceleration = 1000
    
    var playerWidth         = 100
    var playerHeight        = 100
    var coinRadius          = 50
    var enemy1Widths        = [30, 50]
    var enemy1Heights       = [30, 50]
    var groundWidths        = [4000]
    var groundHeights       = [100]
    var wallWidths          = [Int]()
    var wallHeights         = [Int]()
    var jumpableWallWidths  = [Int]()
    var jumpableWallHeights = [Int]()
    
    let coinPositions   : [[Int]] = [[200, 200],
                                     [500, 300],
                                     [600, 400],
                                     [1000, 600],
                                     [1100, 700]]
    
    let enemy1Positions : [[Int]] = [[200, 400],
                                     [600, 400],
                                     [200, 400],
                                     [1300, 600],
                                     [1500, 800]]
    
    let groundPositions       : [[Int]] = [[2000, 50]]
    
    let wallPositions         : [[Int]] = [[Int]]()
    
    let jumpableWallPositions : [[Int]] = [[Int]]()
    
    var coins         = [SKShapeNode]()
    var enemy1s       = [SKShapeNode]()
    var grounds       = [SKShapeNode]()
    var walls         = [SKShapeNode]()
    var jumpableWalls = [SKShapeNode]()
    
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        
        cam = SKCameraNode()
        self.camera = cam
        
        player = SKShapeNode(rectOf: CGSize(width: CGFloat(playerWidth), height: CGFloat(playerHeight)))
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: playerWidth, height: playerHeight))
        
        player.physicsBody?.affectedByGravity  = true
        player.physicsBody?.isDynamic          = true
        player.physicsBody?.pinned             = false
        player.physicsBody?.allowsRotation     = false
        player.physicsBody?.restitution        = 0
        
        player.physicsBody?.categoryBitMask    = playerCategory
        player.physicsBody?.collisionBitMask   = groundCategory
        player.physicsBody?.contactTestBitMask = groundCategory | enemy1Category | coinCategory
        
        player.position = CGPoint(x: 300, y: 300)
        self.addChild(player)
        
        for i in 0..<coinPositions.count {
            let coin = SKShapeNode(circleOfRadius: CGFloat(coinRadius))
            coin.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(coinRadius))
            
            coin.physicsBody?.affectedByGravity  = false
            coin.physicsBody?.isDynamic          = false
            coin.physicsBody?.pinned             = true
            coin.physicsBody?.allowsRotation     = false
            
            coin.physicsBody?.categoryBitMask    = coinCategory
            coin.physicsBody?.collisionBitMask   = 0
            coin.physicsBody?.contactTestBitMask = playerCategory
            
            coin.position.x = CGFloat(Double(coinPositions[i][0]))
            coin.position.y = CGFloat(Double(coinPositions[i][1]))
            
            coins.append(coin)
            self.addChild(coin)
        }
        
        for i in 0..<groundPositions.count {
            let ground = SKShapeNode(rectOf: CGSize(width: CGFloat(groundWidths[i]), height: CGFloat(groundHeights[i])))
            ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(groundWidths[i]), height: CGFloat(groundHeights[i])))
            
            ground.physicsBody?.affectedByGravity  = false
            ground.physicsBody?.isDynamic          = false
            ground.physicsBody?.pinned             = true
            ground.physicsBody?.allowsRotation     = false
            ground.physicsBody?.restitution        = 0
            
            ground.physicsBody?.categoryBitMask    = groundCategory
            ground.physicsBody?.collisionBitMask   = playerCategory
            ground.physicsBody?.contactTestBitMask = playerCategory
            
            ground.position.x = CGFloat(Double(groundPositions[i][0]))
            ground.position.y = CGFloat(Double(groundPositions[i][1]))
            
            coins.append(ground)
            self.addChild(ground)
        }
        
        
        
    }
    
    
   
    override func update(_ currentTime: TimeInterval) {
        if (moveRight || moveLeft) && abs(player?.physicsBody?.velocity.dx ?? 0) < CGFloat(Double(runMaxSpeed)) {
            var multiplier = -1
            if moveRight {
                multiplier = 1
            }
            player?.physicsBody?.applyForce(CGVector(dx: multiplier * runAcceleration, dy: 0))
        }
        
        cam.position.x = player.position.x
        cam.position.y = player.position.y
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print(contact.bodyA.categoryBitMask)
        print(contact.bodyB.categoryBitMask)
        var player : SKShapeNode!
        var ground : SKShapeNode!
        if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == groundCategory {
            player = contact.bodyA.node as? SKShapeNode
            ground = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == groundCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            ground = contact.bodyA.node as? SKShapeNode
        }
        if player != nil && ground != nil {
            jumpNum = 0
        }
    }
}
