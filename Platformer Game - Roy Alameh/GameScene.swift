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
    
    var player   : SKShapeNode!
    var cam      : SKCameraNode!
    var levelEnd : SKShapeNode!
    
    var camInitiateFollowX = 300
    var camInitiateFollowY = 150
    
    var playerStartX = 300
    var playerStartY = 600
    
    let playerCategory         : UInt32 = 0x1 << 0
    let groundCategory         : UInt32 = 0x1 << 1
    let coinCategory           : UInt32 = 0x1 << 2
    let enemy1Category         : UInt32 = 0x1 << 3
    let enemy2Category         : UInt32 = 0x1 << 4
    let enemy3Category         : UInt32 = 0x1 << 5
    let wallCategory           : UInt32 = 0x1 << 6
    let jumpableWallCategory   : UInt32 = 0x1 << 7
    let levelEndCategory       : UInt32 = 0x1 << 8
    
    let jumpSpeed       = 700
    let runMaxSpeed     = 400
    let runAcceleration = 3000
    
    let enemy1Speed = 200
    
    let playerWidth         = 100
    let playerHeight        = 100
    let coinRadius          = 15
    let enemy1Size          = [30, 50]
    let groundSizes         = [[2000, 100],
                               [20, 50],
                               [750, 50],
                               [60, 20],
                               [1000, 20]]
    
    let wallSizes           = [[20, 300],
                               [20, 300],
                               [50, 48],
                               [50, 200],
                               [50, 150]]
    
    let jumpableWallSizes   = [[20, 1000],
                               [20, 1000],
                               [20, 1000],
                               [50, 1000],
                               [50, 800]]
    
    let coinPositions   : [[Int]] = [[200, 200],
                                     [500, 300],
                                     [600, 400],
                                     [1000, 600],
                                     [1100, 700]]
    
    let enemy1Positions : [[Int]] = [[750, 310],
                                     [2250, 310],
                                     [2400, 310],
                                     [2550, 310],
                                     [2750, 310],
                                     [2850, 310]]
    
    let groundPositions       : [[Int]] = [[1000, 50],
                                           [1500, 600],
                                           [2525, 300],
                                           [2925, 1485],
                                           [3870, 1485]]
    
    let wallPositions         : [[Int]] = [[500, 100],
                                           [1000, 100],
                                           [2125, 300],
                                           [2175, 375],
                                           [2925, 350]]
    
    let jumpableWallPositions : [[Int]] = [[1500, 100],
                                           [1100, 950],
                                           [1900, 950],
                                           [3400, 975],
                                           [2925, 1075]]
    
    let levelEndPosition = [4200, 1550]
    
    var coins           = [SKShapeNode]()
    var enemy1s         = [SKShapeNode]()
    var enemy1sAnimated = [SKShapeNode]()
    var grounds         = [SKShapeNode]()
    var walls           = [SKShapeNode]()
    var jumpableWalls   = [SKShapeNode]()
    
    var inspectMode             = false
    var inspectInitialPositionX = 0
    var inspectInitialPositionY = 0
    var lastTouchX              : CGFloat!
    var lastTouchY              : CGFloat!
    
    var lives = 3
    var inAnimation = false
    var initialPositionYAnimation : CGFloat = 0
    
    var totalCoins = 0
    var coinsLabel : SKLabelNode!
    var livesLabel : SKLabelNode!
    
    var inspectOutlet     : SKLabelNode!
    var teleportOutlet    : SKLabelNode!
    var rightButtonOutlet : SKLabelNode!
    var leftButtonOutlet  : SKLabelNode!
    var smallJumpOutlet   : SKLabelNode!
    var largeJumpOutlet   : SKLabelNode!
    
    var jumpableWallAnimation = false
    var xVelocity             : CGFloat!
    var horizontalHopVelocity = 500
    var wallSlideVelocity     = 100
    
    var firstInit = true
    
    var timeToWait    = 0.4
    var timeWaited    = 0.0
    var canMove       = true
    var animationRate = 0.001
    
    let movementOutletSize = 250
    
    var rightLeg    : SKShapeNode!
    var leftLeg     : SKShapeNode!
    var rightArm    : SKShapeNode!
    var leftArm     : SKShapeNode!
    
    var maxAngle : Double = Double.pi/4
    var direction         = 1
    var legLength         = 250
    var armLength         = 100
    var legCenterPoint    = CGPoint(x: 200, y: 400)
    var armCenterPoint    = CGPoint(x: 0, y: 500)
    var testPoint2 : SKShapeNode!
    
    var correctionConstant = 0.0
    
    var joint : SKPhysicsJoint!
    var centerOfMass: SKShapeNode!
    
    var lastSpeed = 0
    
    var touchingGround = false
    
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        
        cam = SKCameraNode()
        self.camera = cam
        
        initPlayer(fromBegining: true)
        
        levelEnd = SKShapeNode(circleOfRadius: 50)
        levelEnd.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        
        levelEnd.physicsBody?.affectedByGravity  = false
        levelEnd.physicsBody?.pinned             = true
        levelEnd.physicsBody?.categoryBitMask    = levelEndCategory
        levelEnd.physicsBody?.collisionBitMask   = 0
        levelEnd.physicsBody?.contactTestBitMask = playerCategory
        
        levelEnd.position.x = CGFloat(levelEndPosition[0])
        levelEnd.position.y = CGFloat(levelEndPosition[1])
        
        self.addChild(levelEnd)

        cam.position.x = player.position.x
        cam.position.y = player.position.y
        
        coinsLabel                 = SKLabelNode()
        coinsLabel.text            = "Coins: \(totalCoins)"
        self.addChild(coinsLabel)
        
        livesLabel                 = SKLabelNode()
        livesLabel.text            = "Lives: \(lives)"
        self.addChild(livesLabel)
        
        inspectOutlet              = SKLabelNode()
        inspectOutlet.text         = "Inspect"
        inspectOutlet.name         = "inspectOutlet"
        inspectOutlet.fontSize     = 30
        self.addChild(inspectOutlet)
        
        teleportOutlet             = SKLabelNode()
        teleportOutlet.text        = "Teleport"
        teleportOutlet.name        = "teleportOutlet"
        teleportOutlet.fontSize    = 30
        teleportOutlet.isHidden    = true
        self.addChild(teleportOutlet)
        
        rightButtonOutlet          = SKLabelNode()
        rightButtonOutlet.text     = "►"
        rightButtonOutlet.name     = "rightButtonOutlet"
        rightButtonOutlet.fontSize = CGFloat(movementOutletSize)
        self.addChild(rightButtonOutlet)
        
        leftButtonOutlet           = SKLabelNode()
        leftButtonOutlet.text      = "◄"
        leftButtonOutlet.name      = "leftButtonOutlet"
        leftButtonOutlet.fontSize  = CGFloat(movementOutletSize)
        self.addChild(leftButtonOutlet)
        
        /*smallJumpOutlet            = SKLabelNode()
        smallJumpOutlet.text       = "▲"
        smallJumpOutlet.name       = "smallJumpOutlet"
        smallJumpOutlet.fontSize   = CGFloat(movementOutletSize)
        self.addChild(smallJumpOutlet)*/
        
        largeJumpOutlet            = SKLabelNode()
        largeJumpOutlet.text       = "⍙"
        largeJumpOutlet.name       = "largeJumpOutlet"
        largeJumpOutlet.fontSize   = CGFloat(movementOutletSize)
        self.addChild(largeJumpOutlet)
        
        
        let legSize = CGSize(width: 10, height: legLength)
        rightLeg = SKShapeNode(rectOf: legSize)
        rightLeg.physicsBody = SKPhysicsBody(rectangleOf: legSize)
        rightLeg.physicsBody?.mass = 0.001
        rightLeg.position.x = 100
        rightLeg.position.y = 310
        rightLeg.physicsBody?.affectedByGravity = false
        rightLeg.physicsBody?.pinned = false
        rightLeg.physicsBody?.allowsRotation = true
        rightLeg.physicsBody?.categoryBitMask = 0
        rightLeg.physicsBody?.collisionBitMask = 0
        
        centerOfMass = SKShapeNode(circleOfRadius: 1)
        centerOfMass.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        centerOfMass.position.x = rightLeg.position.x
        centerOfMass.position.y = rightLeg.position.y + CGFloat(legLength)/2
        centerOfMass.physicsBody?.mass = 10
        centerOfMass.physicsBody?.affectedByGravity = false
        centerOfMass.physicsBody?.pinned = false
        centerOfMass.physicsBody?.allowsRotation = true
        centerOfMass.physicsBody?.categoryBitMask = 0
        centerOfMass.physicsBody?.collisionBitMask = 0
        
        self.addChild(rightLeg)
        self.addChild(centerOfMass)
        var body = SKPhysicsBody(bodies: [rightLeg.physicsBody, centerOfMass.physicsBody] as! [SKPhysicsBody])
        
        joint = SKPhysicsJointFixed.joint(withBodyA: rightLeg.physicsBody!, bodyB: centerOfMass.physicsBody!, anchor: rightLeg.position)
        
        
        
        self.physicsWorld.add(joint)
        
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
            ground.physicsBody?.friction           = 0
            
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
        player.physicsBody?.linearDamping      = 0
        player.physicsBody?.friction           = 0
        player.physicsBody?.mass = 1
        
        if fromBegining {
            player.physicsBody?.angularVelocity    = 0
            player.zRotation                       = 0
            player.physicsBody?.velocity.dx        = 0
            player.physicsBody?.velocity.dy        = 0
            player.position = CGPoint(x: playerStartX , y: playerStartY)
            rightStop()
            leftStop()
        }
        
        player.physicsBody?.categoryBitMask    = playerCategory
        player.physicsBody?.collisionBitMask   = groundCategory | wallCategory | jumpableWallCategory
        player.physicsBody?.contactTestBitMask = groundCategory | enemy1Category | coinCategory
        
        if firstInit {
            self.addChild(player)
            firstInit = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (moveRight || moveLeft) && !inAnimation && canMove {
            var multiplier = 0
            if moveRight && (player.physicsBody?.velocity.dx)! < CGFloat(runMaxSpeed) {
                multiplier = 1
            }
            else if moveLeft && (player.physicsBody?.velocity.dx)! > CGFloat(-runMaxSpeed) {
                multiplier = -1
            }
//            else {
//                player.physicsBody?.velocity.dx = CGFloat(CGFloat(runMaxSpeed) * (player.physicsBody?.velocity.dx ?? 0)/abs(player.physicsBody?.velocity.dx ?? 0))
//            }
            player?.physicsBody?.applyForce(CGVector(dx: CGFloat(multiplier * runAcceleration) * (player.physicsBody?.mass ?? 1), dy: 0))
        }
        else if ((player.physicsBody?.velocity.dx)! > 5 && touchingGround) {
            player?.physicsBody?.applyForce(CGVector(dx: CGFloat(-1 * runAcceleration) * (player.physicsBody?.mass ?? 1), dy: 0))
        }
        else if ((player.physicsBody?.velocity.dx)! < -5 && touchingGround) {
            player?.physicsBody?.applyForce(CGVector(dx: CGFloat(runAcceleration) * (player.physicsBody?.mass ?? 1), dy: 0))
        }

        if !inspectMode && (!inAnimation || jumpableWallAnimation) && player.position.y > -1000 {
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
        else if inAnimation && !jumpableWallAnimation {
            if (player.position.y <= initialPositionYAnimation - CGFloat(2000)) {
                initPlayer(fromBegining: true)
                inAnimation = false
                lives -= 1
                if (lives == 0) {
                    end(won: false)
                }
                if lives != 0 {
                    livesLabel.text = "Lives: \(lives)"
                }
            }
        }
        //if (!canMove)
        
        print(player.physicsBody?.velocity.dx)
        
        
        
        if (Double(rightLeg.physicsBody?.node?.zRotation ?? 0) > maxAngle) {
            direction = -1
        }
        else if (Double(rightLeg.physicsBody?.node?.zRotation ?? 0) < -maxAngle) {
            direction = 1
        }

        rightLeg?.physicsBody?.angularVelocity = CGFloat(direction) * abs((player.physicsBody?.velocity.dx)!) / CGFloat(legLength)
        
        //legCenterPoint = player.position
        
        centerOfMass.position.x = legCenterPoint.x
        centerOfMass.position.y = legCenterPoint.y

//        testPoint2.position.x = rightLeg.position.x
//        testPoint2.position.y = rightLeg.position.y
        
        print(cam.position.x)
        print(cam.position.y)
        
        coinsLabel.position.x        = cam.position.x - 500
        coinsLabel.position.y        = cam.position.y + 250
        livesLabel.position.x        = cam.position.x - 500
        livesLabel.position.y        = cam.position.y + 200
        inspectOutlet.position.x     = cam.position.x + 500
        inspectOutlet.position.y     = cam.position.y + 250
        teleportOutlet.position.x    = cam.position.x - 500
        teleportOutlet.position.y    = cam.position.y + 150
        rightButtonOutlet.position.x = cam.position.x - 370
        rightButtonOutlet.position.y = cam.position.y - 250
        leftButtonOutlet.position.x  = cam.position.x - 570
        leftButtonOutlet.position.y  = cam.position.y - 250
        largeJumpOutlet.position.x   = cam.position.x + 500
        largeJumpOutlet.position.y   = cam.position.y - 250
        
        if ((player.physicsBody?.velocity.dx)! > 5 || (player.physicsBody?.velocity.dx)! < -5) {
            xVelocity = player.physicsBody?.velocity.dx
        }
        
        if (player.position.y <= -3000) {
            initPlayer(fromBegining: true)
            lives -= 1
            if (lives == 0) {
                end(won: false)
            }
            if (lives != 0) {
                livesLabel.text = "Lives: \(lives)"
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var player       : SKShapeNode!
        var ground       : SKShapeNode!
        var enemy1       : SKShapeNode!
        var wall         : SKShapeNode!
        var coin         : SKShapeNode!
        var jumpableWall : SKShapeNode!
        var levelEnd     : SKShapeNode!
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
        else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == levelEndCategory {
            player = contact.bodyA.node as? SKShapeNode
            levelEnd = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == levelEndCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            levelEnd = contact.bodyA.node as? SKShapeNode
        }
        
        if player != nil && ground != nil {
            jumpNum = 0
            touchingGround = true
        }
        else if enemy1 != nil && wall != nil {
            enemy1.physicsBody?.velocity.dx *= -1
        }
        else if player != nil && enemy1 != nil {
            if Int(player.position.y - enemy1.position.y) >= (playerHeight + enemy1Size[1])/2 - 10 {
                player.physicsBody?.velocity.dy = CGFloat(jumpSpeed)
                enemy1.physicsBody?.velocity.dy = 0
                enemy1.physicsBody?.velocity.dx = 0
                let texture = self.view?.texture(from: enemy1)
                let enemy1Sprite = SKSpriteNode(texture: texture)
                enemy1Sprite.position = enemy1.position
                enemy1.removeFromParent()
                self.addChild(enemy1Sprite)
                
                let duration = 0.5
                enemy1Sprite.run(SKAction.moveTo(y: enemy1Sprite.position.y - enemy1Sprite.frame.height / 2, duration: TimeInterval(duration)))
                enemy1Sprite.run(SKAction.sequence([SKAction.resize(toWidth: enemy1.frame.width * 1.25, height: 0, duration: TimeInterval(duration)), SKAction.removeFromParent()]))
            }
            else {
                dieAnimation()
            }
        }
        else if coin != nil && player != nil {
            totalCoins += 1
            coinsLabel.text = "Coins: \(totalCoins)"
            coin.removeFromParent()
        }
        else if player != nil && jumpableWall != nil {
            jumpNum = maxJumps - 1
            jumpableWallAnimation = true
            inAnimation = true
            player.physicsBody?.velocity.dx = 0
            player.physicsBody?.velocity.dy = CGFloat(-wallSlideVelocity)
            player.physicsBody?.linearDamping = 0
            player.physicsBody?.affectedByGravity = false
        }
        else if player != nil && levelEnd != nil {
            print("test")
            //end(won: true)
        }
    }
    
    func end(won: Bool) {
        var gameScene : EndScene!
        if let scene = GKScene(fileNamed: "EndScene") {
            gameScene = scene.rootNode as? EndScene
            gameScene.entities = scene.entities
            gameScene.graphs = scene.graphs
            gameScene.scaleMode = .aspectFill
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 3)
                view.presentScene(gameScene, transition: transition)
                view.ignoresSiblingOrder = true
                view.showsFPS = false
                view.showsNodeCount = false
            }
        }
        if won {
            gameScene.label.text = "You Win!"
        }
        else {
            gameScene.label.text = "You Lost"
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var player       : SKShapeNode!
        var jumpableWall : SKShapeNode!
        var ground       : SKShapeNode!
        if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == jumpableWallCategory {
            player = contact.bodyA.node as? SKShapeNode
            jumpableWall = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == jumpableWallCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            jumpableWall = contact.bodyA.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == groundCategory {
            player = contact.bodyA.node as? SKShapeNode
            ground = contact.bodyB.node as? SKShapeNode
        }
        else if contact.bodyA.categoryBitMask == groundCategory && contact.bodyB.categoryBitMask == playerCategory {
            player = contact.bodyB.node as? SKShapeNode
            ground = contact.bodyA.node as? SKShapeNode
        }
        
        if (player != nil && jumpableWall != nil && jumpableWallAnimation) {
            initPlayer(fromBegining: false)
            jumpableWallAnimation = false
            inAnimation = false
        }
        else if (player != nil && ground != nil) {
            touchingGround = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            lastTouchX = touch.location(in: self).x
            lastTouchY = touch.location(in: self).y
            
            if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "inspectOutlet" {
                inspectAction()
            }
            else if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "teleportOutlet" {
                teleportAction()
            }
            else if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "rightButtonOutlet" {
                rightAction()
            }
            else if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "leftButtonOutlet" {
                leftAction()
            }
            else if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "smallJumpOutlet" {
                jumpAction()
            }
            else if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "largeJumpOutlet" {
                jumpAction()
            }
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            print(touch.location(in: self).x)
        }
        for touch in touches {
            if moveRight || moveLeft {
                if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "rightButtonOutlet" {
                    rightStop()
                }
                if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "leftButtonOutlet" {
                    leftStop()
                }
            }
        }
    }
    
    func rightAction() {
        if !inAnimation {
            moveRight = true
        }
    }
    
    func jumpAction() {
        if !inAnimation {
            if jumpNum < maxJumps {
                player.physicsBody?.velocity.dy = CGFloat(jumpSpeed)
                jumpNum += 1
            }
        }
        else if inAnimation && jumpableWallAnimation {
            player.physicsBody?.velocity.dy = CGFloat(jumpSpeed)
            if xVelocity > 0 {
                player?.physicsBody?.velocity.dx = -CGFloat(horizontalHopVelocity)
            }
            else {
                player.physicsBody?.velocity.dx = CGFloat(horizontalHopVelocity)
            }
            canMove = false
            initPlayer(fromBegining: false)
            jumpableWallAnimation = false
            inAnimation = false
            //lastSpeed = player.physicsBody?.velocity.dx
            DispatchQueue.main.asyncAfter(deadline: .now() + timeToWait, execute: {
                self.canMove = true
            })
        }
    }
    
    func leftAction() {
        if !inAnimation {
            moveLeft = true
        }
    }
    
    func rightStop() {
        moveRight = false
    }
    
    func leftStop() {
        moveLeft = false
    }
    
    func inspectAction() {
        if inspectMode == false {
            inspectInitialPositionX = Int(cam.position.x)
            inspectInitialPositionY = Int(cam.position.y)
            inspectMode = true
            inspectOutlet.color = UIColor.green
            teleportOutlet.isHidden = false
        }
        else {
            inspectMode = false
            inspectOutlet.color = UIColor.systemBlue
            teleportOutlet.isHidden = true
        }
    }
    
    func teleportAction() {
        player.position.x = cam.position.x
        player.position.y = cam.position.y
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
