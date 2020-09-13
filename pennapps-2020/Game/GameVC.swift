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
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionLabel: UILabel!
    
    var isDemo = false
    
    var redFlag = newFlagNode(team: .red)
    var blueFlag = newFlagNode(team: .blue)
    
    var testPlayer = newPlayerNode(team: .red)
    var testPlayerFlag = newPlayerWithFlagNode(team: .blue)
    var field = buildField()
    
    let config = ARWorldTrackingConfiguration()
    
    var delegate: LobbyVC?
    var viewModel: GameViewModel!
    
    var team = Team.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        arView.delegate = self
        arView.session.run(config)
        arView.session.delegate = self
        
        //let node = SCNNode(geometry: )
                
        redFlag.position = SCNVector3(0, 0, -10)
        blueFlag.position = SCNVector3(0, 0, 10)

        testPlayer.position = SCNVector3(0, 0, -2)
        testPlayer.position = SCNVector3(2, 0 , -2)
            
        //       self.arView.scene.rootNode.addChildNode(redFlag)
        //        self.arView.scene.rootNode.addChildNode(blueFlag)
        //        self.arView.scene.rootNode.addChildNode(testPlayer)
        //        self.arView.scene.rootNode.addChildNode(testPlayerFlag)
        self.arView.scene.rootNode.addChildNode(field)
        
        self.navigationController?.navigationBar.isHidden = true
        self.actionButton.titleLabel?.alpha = 1.0
        
        
        // Things after this are for game-only
       guard !isDemo else { return}
        
        viewModel.observeActiveStatus { (error, activeMessage) in
            if (error != nil) {
                print(error)
            } else {
                
                self.actionLabel.text = activeMessage
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.actionLabel.text = ""
                }
            }
        }
        
        viewModel.observeFlagAvailability(flagString: "redFlagAvailable") { (error, available) in
            if (error != nil) {
                print(error)
            } else {
                self.viewModel.redFlagAvailable = available
            }
        }
        
        viewModel.observeFlagAvailability(flagString: "blueFlagAvailable") { (error, available) in
            print("*** blue flag available changed: \(available)")

            if (error != nil) {
                print(error)
            } else {
                self.viewModel.blueFlagAvailable = available
            }
        }
        

        viewModel.observeGamePlayers { (error) in
            if error != nil {
                print(error)
            } else {
//                print(self.viewModel.getGamePlayers())
//                print("userId")
//                print(self.viewModel.userId)
            }
        }
    }
    
    
    @IBAction func pressAction() {
        viewModel.takeAction() { actionMessage in
            self.actionLabel.text = actionMessage
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.actionLabel.text = ""
            }
        }
    }
    
    func updateControls() {
        
        var player = self.viewModel.gamePlayers[self.viewModel.userId]!
        
        guard player.active else {
            actionButton.isEnabled = false
            return
        }
        
        let flagAvail = player.team == 0 ? viewModel.blueFlagAvailable : viewModel.redFlagAvailable
        
        
        if player.isInFlagZone() && flagAvail! { // && view model. flag is available
            actionButton.isHidden = false
            actionButton.setTitle("GET FLAG!", for: .normal)
        } else if player.isInOwnTeamTerritory() {
            actionButton.setTitle("TAG", for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        
        
        
    }
    
    
    
    
    func moveAndRender() {
        
        updateControls()
        
        self.arView.scene.rootNode.enumerateChildNodes() { (node, stop) in
           node.removeFromParentNode()
            
        }
        self.arView.scene.rootNode.addChildNode(buildField())
        if self.viewModel.blueFlagAvailable {
            let node = newFlagNode(team: .blue)
            self.arView.scene.rootNode.addChildNode(node)
            
            node.position = SCNVector3(0, 0, (COURT_LENGTH + SAFE_ZONE_LENGTH) / 2)
            
        }
        
        if self.viewModel.redFlagAvailable {
            let node = newFlagNode(team: .red)
            self.arView.scene.rootNode.addChildNode(node)
            
            node.position = SCNVector3(0, 0, -(COURT_LENGTH + SAFE_ZONE_LENGTH) / 2)
            
        }
        
        for playerID in viewModel.gamePlayers.keys {
            let player = viewModel.gamePlayers[playerID]!

            // Extracting node, removing it from parent, changing p
            var newNode = SCNNode()

            // If the player has a flag, set them to be a
            if player.hasFlag {
                newNode = newPlayerWithFlagNode(team: player.team == 0 ? .red : .blue)
                
            } else {
                newNode = newPlayerNode(team: player.team == 0 ? .red : .blue)
            }
            
            
            
            
            newNode.position = SCNVector3(player.x, 0, player.z)
            viewModel.gamePlayers[playerID]!.node = newNode
            

            // Making sure it has the right color
            var color = player.team == 0 ? UIColor.systemPink : UIColor.systemIndigo
            if !player.active { color = UIColor(named: "\(player.team == 0 ? "red" : "blue")_out")! }

            
            if playerID == viewModel.userId {
                color.withAlphaComponent(0)
            }
            color.withAlphaComponent(0.7)
            newNode.geometry?.firstMaterial?.diffuse.contents = color

            // Adding the child back
            self.arView.scene.rootNode.addChildNode(newNode)
        }
    }
}

extension GameVC: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate currentFrame: ARFrame) {
        let transform = currentFrame.camera.transform
        // UPDATING
        let pos = arView.pointOfView!.position
        
        moveAndRender()
        
        // these are helpful for knowing how to do the rerender
//        self.redFlag.removeFromParentNode()
//        self.redFlag.position = SCNVector3(pos.x, -pos.y, -pos.z)
//        self.arView.scene.rootNode.addChildNode(redFlag)
        
        viewModel.resurrectPlayer()
        
        // Things after here run if it's a real game
            
        viewModel.updatePosition(userId: viewModel.userId, x: Double(pos.x), z: Double(pos.z)) { (error) in
            if error != nil {
                print(error)
            }
        }
    }
}

