//
//  GameVC.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import Firebase
import SceneKit

class GameVC: UIViewController, ARSCNViewDelegate {
        
    
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var xPos: UILabel!
    @IBOutlet weak var yPos: UILabel!
    @IBOutlet weak var zPos: UILabel!
    
    var isDemo = false
    
    var redFlag = newFlagNode(team: .red)
    var blueFlag = newFlagNode(team: .blue)
    
    var testPlayer = newPlayerNode(team: .red)
    var testPlayerFlag = newPlayerWithFlagNode(team: .blue)
    
    var field = buildField()
    
    let config = ARWorldTrackingConfiguration()
    
    var delegate: LobbyVC?
    var viewModel: GameViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arView.delegate = self
        arView.session.run(config)
        arView.session.delegate = self
        
        //let node = SCNNode(geometry: )
                
        redFlag.position = SCNVector3(0, 0, -10)
        blueFlag.position = SCNVector3(0, 0, 10)
        
        testPlayer.position = SCNVector3(0, 0, -2)
        testPlayer.position = SCNVector3(2, 0 , -2)
            
        self.arView.scene.rootNode.addChildNode(redFlag)
//        self.arView.scene.rootNode.addChildNode(blueFlag)
//        self.arView.scene.rootNode.addChildNode(testPlayer)
//        self.arView.scene.rootNode.addChildNode(testPlayerFlag)
        self.arView.scene.rootNode.addChildNode(field)


    }
    
}

extension GameVC: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate currentFrame: ARFrame) {
        let transform = currentFrame.camera.transform
        // UPDATING
        let pos = arView.pointOfView!.position
        self.xPos.text = "\(pos.x)"
        self.yPos.text = "\(pos.y)"
        self.zPos.text = "\(pos.z)"
        
        
        self.redFlag.removeFromParentNode()
        self.redFlag.position = SCNVector3(pos.x, -pos.y, -pos.z)
        self.arView.scene.rootNode.addChildNode(redFlag)
        
        guard isDemo == false else {
            return
        }
        
        // Things after here run if it's a real game
            
        print(viewModel.userId)
        viewModel.updatePosition(userId: viewModel.userId, x: Double(pos.x), z: Double(pos.z)) { (error) in
            if error != nil {
                print(error)
            }
        }
        
        
        
        
       
    }
}

