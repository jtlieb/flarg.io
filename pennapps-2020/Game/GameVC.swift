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
    let config = ARWorldTrackingConfiguration()
    
    var delegate: LobbyVC!
    var gamePlayers: [GamePlayer]!
    
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
        print(transform)
        print("Updates")                               // UPDATING
    }
}
