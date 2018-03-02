//
//  ViewController.swift
//  ARBallToss
//
//  Created by Andre Faruolo on 27/02/2018.
//  Copyright © 2018 Andre Faruolo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let planes = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         configureLighting()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [SCNDebugOptions.showBoundingBoxes, SCNDebugOptions.showPhysicsShapes]
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        addBackboard()
        registerGestureRecognizer()
        
    }
    
    func registerGestureRecognizer() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer){
        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
            return
        }
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        let cameraTransform = centerPoint.transform
        
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        let ball = SCNSphere(radius: 0.15)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        
        let color = SCNMaterial()
        color.diffuse.contents = UIColor.white
        
        ball.materials = [material, color]
        
        let ballNode = SCNNode(geometry: ball)
        
        ballNode.position = cameraPosition
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options : nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        ballNode.physicsBody = physicsBody
        ballNode.physicsBody?.categoryBitMask = BitMask.ball.rawValue
        ballNode.physicsBody?.collisionBitMask = BitMask.plane.rawValue
        ballNode.physicsBody?.restitution = 1
        
        let forceVector: Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: cameraOrientation.y * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    
    func addBackboard() {
        
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else {
            return
        }
        
        backboardNode.position = SCNVector3(x: 0,y: 0.5,z: -3)
        
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody
        backboardNode.physicsBody?.restitution = 0
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        horizontalAction(node: backboardNode)
        
        
    }
    
    func horizontalAction(node: SCNNode) {
        
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showBoundingBoxes, SCNDebugOptions.showPhysicsShapes]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let plane = Plane(with: planeAnchor)
        self.planes.setObject(plane, forKey: planeAnchor.identifier as NSCopying)
        
        node.addChildNode(plane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = self.planes.object(forKey: planeAnchor.identifier) as? Plane
            else { return }
        
        planeNode.update(with: planeAnchor)
    
}
    
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}




