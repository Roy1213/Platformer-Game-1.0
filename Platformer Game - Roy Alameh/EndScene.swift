//
//  WinScene.swift
//  Platformer Game - Roy Alameh
//
//  Created by Roy Alameh on 2/16/23.
//

import SpriteKit
import GameplayKit
import UIKit
import Foundation

class EndScene : SKScene {
    
    var entities = [GKEntity]()
    var graphs   = [String : GKGraph]()
    
    var label : SKLabelNode!
    var cam : SKCameraNode!
    var playAgainLabel: SKLabelNode!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        label = SKLabelNode()
        label.fontName = "Zapfino"
        label.fontSize = 100
        
        playAgainLabel = SKLabelNode()
        playAgainLabel.fontName = "Zapfino"
        playAgainLabel.fontSize = 30
        playAgainLabel.position.x = label.position.x
        playAgainLabel.position.y = label.position.y - 80
        playAgainLabel.text = "Play Again?"
        playAgainLabel.name = "playAgainLabel"
        
        cam = SKCameraNode()
        self.camera = cam
        
        cam.position.x = label.position.x
        cam.position.y = label.position.y
        
        self.addChild(label)
        self.addChild(cam)
        self.addChild(playAgainLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.nodes(at: touch.location(in: self)).count > 0 && self.nodes(at: touch.location(in: self))[self.nodes(at: touch.location(in: self)).count - 1].name == "playAgainLabel" {
                playAgain()
            }
        }
    }
    
    func playAgain() {
        var gameScene : GameScene!
        if let scene = GKScene(fileNamed: "GameScene") {
            gameScene = scene.rootNode as? GameScene
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
    }
}
