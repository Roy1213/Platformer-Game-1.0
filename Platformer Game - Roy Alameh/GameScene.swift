//
//  GameScene.swift
//  Platformer Game - Roy Alameh
//
//  Created by Roy Alameh on 2/9/23.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var player : SKSpriteNode!
    var cheese = 1.0
    
    var jumpSpeed = 600
    var runMaxSpeed = 400
    
    override func sceneDidLoad() {
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft, forKey: "orientation")
        player = self.childNode(withName: "player") as? SKSpriteNode
    }
    
    
   
    override func update(_ currentTime: TimeInterval) {
    }
}
