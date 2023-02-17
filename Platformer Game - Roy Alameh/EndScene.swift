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
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        label = SKLabelNode()
        label.fontName = "Zapfino"
        label.fontSize = 100
        
        cam = SKCameraNode()
        self.camera = cam
        
        cam.position.x = label.position.x
        cam.position.y = label.position.y
        
        self.addChild(label)
        self.addChild(cam)
    }
}
