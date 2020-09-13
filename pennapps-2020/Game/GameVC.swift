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

class GameVC: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var xPos: UILabel!
    @IBOutlet weak var yPos: UILabel!
    @IBOutlet weak var zPos: UILabel!
    
    let config = ARWorldTrackingConfiguration()
    
    var delegate: LobbyVC!
    var viewModel: GameViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arView.delegate = self
        arView.session.run(config)
        arView.session.delegate = self
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
//        print(viewModel.userId)
        viewModel.updatePosition(userId: viewModel.userId, x: Double(pos.x), z: Double(pos.z)) { (error) in
            if error != nil {
                print(error)
            }
        }
        print("updated pos func done")
        viewModel.observeGamePlayers { (error) in
            if error != nil {
                print(error)
            }
        }
        print("updated game players func done")
       
    }
}
