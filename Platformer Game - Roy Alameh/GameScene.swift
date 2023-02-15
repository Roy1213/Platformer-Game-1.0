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
    
    var camInitiateFollowX = 300
    var camInitiateFollowY = 150
    
    var playerStartX = 300
    var playerStartY = 300
    
    let playerCategory         : UInt32 = 0x1 << 0
    let groundCategory         : UInt32 = 0x1 << 1
    let coinCategory           : UInt32 = 0x1 << 2
    let enemy1Category         : UInt32 = 0x1 << 3
    let enemy2Category         : UInt32 = 0x1 << 4
    let enemy3Category         : UInt32 = 0x1 << 5
    let wallCategory           : UInt32 = 0x1 << 6
    let jumpableWallCategory   : UInt32 = 0x1 << 7
    
    let jumpSpeed       = 700
    let runMaxSpeed     = 400
    let runAcceleration = 3000
    
    let enemy1Speed = 300
    
    let playerWidth         = 100
    let playerHeight        = 100
    let coinRadius          = 15
    let enemy1Size          = [30, 50]
    let groundSizes         = [[4000, 100]]
    let wallSizes           = [[20, 300],
                               [20, 300]]
    
    let jumpableWallSizes   = [[20, 1000],
                               [20, 1000],
                               [20, 1000]]
    
    let coinPositions   : [[Int]] = [[200, 200],
                                     [500, 300],
                                     [600, 400],
                                     [1000, 600],
                                     [1100, 700]]
    
    let enemy1Positions : [[Int]] = [[750, 300]]
    
    let groundPositions       : [[Int]] = [[2000, 50]]
    
    let wallPositions         : [[Int]] = [[500, 100],
                                           [1000, 100]]
    
    let jumpableWallPositions : [[Int]] = [[1500, 100],
                                           [1100, 950],
                                           [1900, 950]]
    
    var coins         = [SKShapeNode]()
    var enemy1s       = [SKShapeNode]()
    var grounds       = [SKShapeNode]()
    var walls         = [SKShapeNode]()
    var jumpableWalls = [SKShapeNode]()
    
    var inspectMode = false
    var inspectInitialPositionX = 0
    var inspectInitialPositionY = 0
    var lastTouchX : CGFloat!
    var lastTouchY : CGFloat!
    
    var lives = 2
    var inAnimation = false
    var initialPositionYAnimation : CGFloat = 0
    
    var totalCoins = 0
    var coinsLabel : SKLabelNode!
    
    var jumpableWallAnimation : Bool!
    var xVelocity             : CGFloat!
    var horizontalHopVelocity = 500
    var wallSlideVelocity     = 20
    
    var firstInit = true
    
    
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        
        cam = SKCameraNode()
        self.camera = cam
        
        initPlayer(fromBegining: true)
        
        cam.position.x = player.position.x
        cam.position.y = player.position.y
        
        coinsLabel = SKLabelNode()
        coinsLabel.text = "Coins: \(totalCoins)"
        self.addChild(coinsLabel)
        
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
            let ground = SKShapeNode(rectOf: CGSize(width: CGFloat(groundSizes[i][0]), height: CGFloat(groundSizes[i][1])))
            ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(groundSizes[i][0]), height: CGFloat(groundSizes[i][1])))
            
            ground.physicsBody?.affectedByGravity  = false
            ground.physicsBody?.isDynamic          = false
            ground.physicsBody?.pinned             = true
            ground.physicsBody?.allowsRotation     = false
            ground.physicsBody?.restitution        = 0
            ground.physicsBody?.friction           = 0.2
            
            ground.physicsBody?.categoryBitMask    = groundCategory
            ground.physicsBody?.collisionBitMask   = playerCategory
            ground.physicsBody?.contactTestBitMask = playerCategory
            
            ground.position.x = CGFloat(Double(groundPositions[i][0]))
            ground.position.y = CGFloat(Double(groundPositions[i][1]))
            
            grounds.append(ground)
            self.addChild(ground)
        }
        
        for i in 0..<enemy1Positions.count {
            let enemy1 = SKShapeNode(rectOf: CGSize(width: CGFloat(enemy1Size[0]), height: CGFloat(enemy1Size[1])))
            enemy1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(enemy1Size[0]), height: CGFloat(enemy1Size[1])))
            
            enemy1.physicsBody?.affectedByGravity  = true
            enemy1.physicsBody?.isDynamic          = true
            enemy1.physicsBody?.pinned             = false
            enemy1.physicsBody?.allowsRotation     = false
            enemy1.physicsBody?.restitution        = 0
            enemy1.physicsBody?.friction           = 0
            enemy1.physicsBody?.angularDamping     = 0
            enemy1.physicsBody?.linearDamping      = 0
            
            enemy1.physicsBody?.categoryBitMask    = enemy1Category
            enemy1.physicsBody?.collisionBitMask   = groundCategory
            enemy1.physicsBody?.contactTestBitMask = playerCategory | wallCategory | jumpableWallCategory
            
            enemy1.position.x = CGFloat(Double(enemy1Positions[i][0]))
            enemy1.position.y = CGFloat(Double(enemy1Positions[i][1]))
            
            enemy1s.append(enemy1)
            self.addChild(enemy1)
            
            enemy1.physicsBody?.velocity.dx = CGFloat(enemy1Speed)
        }
        
        for i in 0..<wallPositions.count {
            let wall = SKShapeNode(rectOf: CGSize(width: CGFloat(wallSizes[i][0]), height: CGFloat(wallSizes[i][1])))
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(wallSizes[i][0]), height: CGFloat(wallSizes[i][1])))
            
            wall.physicsBody?.affectedByGravity  = false
            wall.physicsBody?.isDynamic          = false
            wall.physicsBody?.pinned             = true
            wall.physicsBody?.allowsRotation     = false
            wall.physicsBody?.restitution        = 0
            wall.physicsBody?.friction           = 0
            
            wall.physicsBody?.categoryBitMask    = wallCategory
            wall.physicsBody?.collisionBitMask   = playerCategory
            wall.physicsBody?.contactTestBitMask = playerCategory | enemy1Category
            
            wall.position.x = CGFloat(Double(wallPositions[i][0]))
            wall.position.y = CGFloat(Double(wallPositions[i][1]))
            
            walls.append(wall)
            self.addChild(wall)
        }
        
        for i in 0..<jumpableWallPositions.count {
            let jumpableWall = SKShapeNode(rectOf: CGSize(width: CGFloat(jumpableWallSizes[i][0]), height: CGFloat(jumpableWallSizes[i][1])))
            jumpableWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(jumpableWallSizes[i][0]), height: CGFloat(jumpableWallSizes[i][1])))
            
            jumpableWall.physicsBody?.affectedByGravity  = false
            jumpableWall.physicsBody?.isDynamic          = false
            jumpableWall.physicsBody?.pinned             = true
            jumpableWall.physicsBody?.allowsRotation     = false
            jumpableWall.physicsBody?.restitution        = 0
            jumpableWall.physicsBody?.friction           = 0
            
            jumpableWall.physicsBody?.categoryBitMask    = jumpableWallCategory
            jumpableWall.physicsBody?.collisionBitMask   = playerCategory
            jumpableWall.physicsBody?.contactTestBitMask = playerCategory | enemy1Category
            
            jumpableWall.position.x = CGFloat(Double(jumpableWallPositions[i][0]))
            jumpableWall.position.y = CGFloat(Double(jumpableWallPositions[i][1]))
            
            walls.append(jumpableWall)
            self.addChild(jumpableWall)
        }
    }
    
    func initPlayer(fromBegining : Bool) {
        if firstInit {
            player = SKShapeNode(rectOf: CGSize(width: CGFloat(playerWidth), height: CGFloat(playerHeight)))
            player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: playerWidth, height: playerHeight))
        }
        
        player.physicsBody?.affectedByGravity  = true
        player.physicsBody?.isDynamic          = true
        player.physicsBody?.pinned             = false
        player.physicsBody?.allowsRotation     = false
        player.physicsBody?.restitution        = 0
        player.physicsBody?.linearDamping      = 0.5
        player.physicsBody?.friction           = 1
        player.physicsBody?.angularVelocity    = 0
        
        player.physicsBody?.categoryBitMask    = playerCategory
        player.physicsBody?.collisionBitMask   = groundCategory | wallCategory | jumpableWallCategory
        player.physicsBody?.contactTestBitMask = groundCategory | enemy1Category | coinCategory
        
        if fromBegining {
            player.position = CGPoint(x: playerStartX , y: playerStartY)
        }
        
        if firstInit {
            self.addChild(player)
            firstInit = false
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if (moveRight || moveLeft) && abs(player?.physicsBody?.velocity.dx ?? 0) < CGFloat(Double(runMaxSpeed)) && !inAnimation {
            var multiplier = -1
            if moveRight {
                multiplier = 1
            }
            player?.physicsBody?.applyForce(CGVector(dx: multiplier * runAcceleration, dy: 0))
        }
        if !inspectMode && !inAnimation{
            if abs(player.position.x - cam.position.x) >= CGFloat(camInitiateFollowX) {
                if player.position.x > cam.position.x {
                    cam.position.x += player.position.x - cam.position.x - CGFloat(camInitiateFollowX)
                }
                else {
                    cam.position.x += player.position.x - cam.position.x + CGFloat(camInitiateFollowX)
                }
            }
            if abs(player.position.y - cam.position.y) >= CGFloat(camInitiateFollowY) {
                if player.position.y > cam.position.y {
                    cam.position.y += player.position.y - cam.position.y - CGFloat(camInitiateFollowY)
                }
                else {
                    cam.position.y += player.position.y - cam.position.y + CGFloat(camInitiateFollowY)
                }
            }
        }
        else if inAnimation && jumpableWallAnimation == nil || jumpableWallAnimation != nil && !jumpableWallAnimation {
            if (player.position.y <= initialPositionYAnimation - CGFloat(2000)) {
                print("the great testing")
                initPlayer(fromBegining: true)
                inAnimation = false
            }
        }
        
        if !inAnimation {
            coinsLabel.position.x = cam.position.x - 500
            coinsLabel.position.y = cam.position.y + 250
        }
        
        if ((player.physicsBody?.velocity.dx)! > 5 || (player.physicsBody?.velocity.dx)! < -5) {
            xVelocity = player.physicsBody?.velocity.dx
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var player       : SKShapeNode!
        var ground       : SKShapeNode!
        var enemy1       : SKShapeNode!
        var wall         : SKShapeNode!
        var coin         : SKShapeNode!
        var jumpableWall : SKShapeNode!
        if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == groundCategory {
            player = contact.bodyA.node as? SKShapeNode
            ground = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == groundCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            ground = contact.bodyA.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == enemy1Category && contact.bodyB.categoryBitMask == wallCategory {
            enemy1 = contact.bodyA.node as? SKShapeNode
            wall = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == wallCategory && contact.bodyB.categoryBitMask == enemy1Category {
            enemy1 = contact.bodyB.node as? SKShapeNode
            wall = contact.bodyA.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == enemy1Category {
            player = contact.bodyA.node as? SKShapeNode
            enemy1 = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == enemy1Category && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            enemy1 = contact.bodyA.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == coinCategory {
            player = contact.bodyA.node as? SKShapeNode
            coin = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == coinCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            coin = contact.bodyA.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == jumpableWallCategory {
            player = contact.bodyA.node as? SKShapeNode
            jumpableWall = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == jumpableWallCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            jumpableWall = contact.bodyA.node as? SKShapeNode
        }
        
        if player != nil && ground != nil {
            jumpNum = 0
            if jumpableWallAnimation != nil && jumpableWallAnimation {
                player.physicsBody?.affectedByGravity = true
                jumpableWallAnimation = false
                inAnimation = false
            }
        }
        else if enemy1 != nil && wall != nil {
            enemy1.physicsBody?.velocity.dx *= -1
        }
        else if player != nil && enemy1 != nil {
            dieAnimation()
        }
        else if coin != nil && player != nil {
            totalCoins += 1
            coinsLabel.text = "Coins: \(totalCoins)"
            coin.removeFromParent()
        }
        else if player != nil && jumpableWall != nil {
            jumpableWallAnimation = true
            inAnimation = true
            player.physicsBody?.velocity.dx = 0
            player.physicsBody?.velocity.dy = CGFloat(-wallSlideVelocity)
            player.physicsBody?.linearDamping = 0
            player.physicsBody?.affectedByGravity = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            lastTouchX = touch.location(in: self).x
            lastTouchY = touch.location(in: self).y
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if inspectMode {
            for touch in touches {
                cam.position.x += lastTouchX - touch.location(in: self).x
                cam.position.y += lastTouchY - touch.location(in: self).y
            }
        }
    }
    
    func dieAnimation() {
        inAnimation = true
        initialPositionYAnimation = player.position.y
        player.physicsBody?.collisionBitMask   = 0
        player.physicsBody?.contactTestBitMask = 0
        player.physicsBody?.categoryBitMask    = 0
        player.physicsBody?.angularDamping     = 0
        player.physicsBody?.velocity.dy        = 700
        player.physicsBody?.velocity.dx        = 0
        player.physicsBody?.angularVelocity    = 100
    }
}
