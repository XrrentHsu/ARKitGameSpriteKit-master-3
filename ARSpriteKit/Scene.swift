//
//  Scene.swift
//  ARSpriteKit
//
//  Created by Esteban Herrera on 7/4/17.
//  Copyright © 2017 Esteban Herrera. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
        
    let ghostsLabel = SKLabelNode(text: "Ghosts")
    let numberOfGhostsLabel = SKLabelNode(text: "0")
    var creationTime : TimeInterval = 0
    var ghostCount = 0 {
        didSet{
            self.numberOfGhostsLabel.text = "\(ghostCount)"
        }
    }
    
    let killSound = SKAction.playSoundFileNamed("ghost", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        ghostsLabel.fontSize = 20
        ghostsLabel.fontName = "DevanagariSangamMN-Bold"
        ghostsLabel.color = .white
        ghostsLabel.position = CGPoint(x: 40, y: 50)
        addChild(ghostsLabel)
        numberOfGhostsLabel.fontSize = 30
        numberOfGhostsLabel.fontName = "DevanagariSangamMN-Bold"
        numberOfGhostsLabel.color = .white
        numberOfGhostsLabel.position = CGPoint(x: 40, y: 10)
        addChild(numberOfGhostsLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime > creationTime {
            createGhostAnchor()
            creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 6.0))
        }
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func createGhostAnchor(){
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        let _360degrees = 2.0 * Float.pi
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        let rotation = simd_mul(rotateX, rotateY)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        let transform = simd_mul(rotation, translation)
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        ghostCount += 1 //這邊記數
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        if let node = hit.first {
            if node.name == "ghost" {
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                node.run(sequenceAction)
                ghostCount -= 1
            }
            
        }
    }
}
