//
//  PlayerNode.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import SceneKit

func newPlayerNode(team: Team) -> SCNNode {
    
    let player = SCNNode()
    let body = SCNNode()
    let head = SCNNode()
    
    
    body.geometry = SCNBox(width: 0.5, height: 1.5, length: 0.5, chamferRadius: 0.1)
    body.geometry?.firstMaterial?.diffuse.contents = team == .red ? UIColor.red : UIColor.blue
    body.position = SCNVector3(0, -1, 0)
    
    head.geometry = SCNSphere(radius: 0.2)
    head.geometry?.firstMaterial?.diffuse.contents = team == .red ? UIColor.red : UIColor.blue
    head.position = SCNVector3(0, 0.2, 0)
    
    player.addChildNode(body)
    player.addChildNode(head)
    
    
    
    return player
}
