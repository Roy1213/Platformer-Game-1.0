//
//  GameViewController.swift
//  Platformer Game - Roy Alameh
//
//  Created by Roy Alameh on 2/9/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var gameScene : GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill

                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    view.showsNodeCount = false
                }
                
                gameScene = sceneNode
            }
        }
    }
    
    @IBAction func rightAction(_ sender: UIButton) {
        gameScene.moveRight = true
    }
    
    @IBAction func jumpAction(_ sender: UIButton) {
        if gameScene.jumpNum < gameScene.maxJumps {
            gameScene.childNode(withName: "player")?.physicsBody?.velocity.dy = CGFloat(gameScene.jumpSpeed)
            gameScene.jumpNum += 1
        }
    }
    
    @IBAction func leftAction(_ sender: UIButton) {
        gameScene.moveLeft = true
    }
    
    @IBAction func rightStop(_ sender: UIButton) {
        gameScene.moveRight = false
    }
    
    @IBAction func leftStop(_ sender: UIButton) {
        gameScene.moveLeft = false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
