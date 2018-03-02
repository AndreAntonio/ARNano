//
//  Plane.swift
//  ARBallToss
//
//  Created by Andre Faruolo on 28/02/2018.
//  Copyright © 2018 Andre Faruolo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

public enum BitMask:Int{
    case ball = 1
    case plane = 2
}

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(with anchor: ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        
        let width = CGFloat(anchor.extent.x)
        let lenght = CGFloat(anchor.extent.z)
        self.planeGeometry = SCNBox(width: width, height: 0.001, length: lenght, chamferRadius: 0)
        
        let shape = SCNPhysicsShape(geometry: planeGeometry, options : nil)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody?.categoryBitMask = BitMask.plane.rawValue
        planeNode.physicsBody?.collisionBitMask = BitMask.ball.rawValue
        planeNode.simdPosition = float3(anchor.center.x, anchor.center.y, anchor.center.z)
        planeNode.eulerAngles.x = -.pi/2
        planeNode.opacity = 0.5
        
        self.addChildNode(planeNode)
        
    }
    
    func update(with anchor: ARPlaneAnchor) {
        self.simdPosition = float3(anchor.center.x, 0, anchor.center.z)
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        let shape = SCNPhysicsShape(geometry: planeGeometry, options : nil)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    
    
    
}
