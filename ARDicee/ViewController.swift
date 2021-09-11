//
//  ViewController.swift
//  ARDicee
//
//  Created by Joshua Basche on 9/11/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
  
  // Create dice array as empty Scene Node Objects
  var diceArray = [SCNNode]()
  
  @IBOutlet var sceneView: ARSCNView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup Plane Debug
    self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Create Cube
    //    let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
    
    //    // Create Sphere
    //    let sphere = SCNSphere(radius: 0.2)
    //
    //    // Create Material For Cub (red color)
    //    let material = SCNMaterial()
    //    material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpeg")
    //    sphere.materials = [material]
    //
    //    // Create Node Scene For Position Of Cube
    //    let node = SCNNode()
    //    node.position = SCNVector3(0, 0.1, -0.5)
    //
    //    // Give Node Geometry Which Is The Cube
    //    node.geometry = sphere
    //
    //    // Add Node To SceneView
    //    sceneView.scene.rootNode.addChildNode(node)
    
    // Add Default Lighting To Scene
    sceneView.autoenablesDefaultLighting = true
    
    // Create New Scene With Die
    //    let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
    //
    //    if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
    //
    //      diceNode.position = SCNVector3(0, 0, -0.1)
    //
    //      sceneView.scene.rootNode.addChildNode(diceNode)
    //    }
    
    
    
    //    // Create a new scene
    //    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    //
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Setup config for plane detection
    configuration.planeDetection = .horizontal
    
    // Run the view's session
    sceneView.session.run(configuration)
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // Add Delegate to Determine Touches in AR World
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let touchLocation = touch.location(in: sceneView)
      
      if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
        let results = sceneView.session.raycast(query)
        
        if let hitResult = results.first {
          //Create New Scene With Die
          let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
          
          if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(
              hitResult.worldTransform.columns.3.x,
              hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
              hitResult.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
              roll(dice: diceNode)
            
          }
        }
      }
    }
  }
  
  func rollAll() {
    
    if !diceArray.isEmpty {
      for dice in diceArray {
        roll(dice: dice)
      }
    }
    
  }
  
  func roll(dice: SCNNode) {
    // Creates a random number between 1 and 4 and multiply by half pi
    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
    
    dice.runAction(
      SCNAction.rotateBy(
        x: CGFloat(randomX * 5),
        y: 0,
        z: CGFloat(randomZ * 5), //add more rotations in animation
        duration: 0.5)
    )
    
  }
  
  @IBAction func rollAgain(_ sender: UIBarButtonItem) {
    rollAll()
  }
  
  @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
    if !diceArray.isEmpty {
      for dice in diceArray {
        dice.removeFromParentNode()
      }
    }
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    rollAll()
  }
  
  // Add Delegate for ARAnchor Plane Detection
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if anchor is ARPlaneAnchor {
      
      // Set variable as ARPlaneAnchor
      let planeAnchor = anchor as! ARPlaneAnchor
      
      // Set Plane Dimensions NOTE HEIGHT IS Z NOT Y
      let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
      
      let planeNode =  SCNNode()
      
      // Set planeNode Position NOTE Y IS 0 BECAUSE ITS A FLAT SURFACE
      planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
      
      // planeNode is set Vertically So Need to roatate it clockwise Horizonatally NOTE Rotation Degree is in Radians (1 Radian = 180 degrees) and is defaulted to Counter Clockwise so -Float.pi/2 to rotate 90 degrees Clockwise
      planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
      
      let gridMaterial = SCNMaterial()
      
      gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
      
      plane.materials = [gridMaterial]
      
      planeNode.geometry = plane
      
      node.addChildNode(planeNode)
      
    } else {
      return
    }
  }
  
}

