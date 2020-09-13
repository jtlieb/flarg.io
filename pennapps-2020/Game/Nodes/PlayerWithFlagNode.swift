//
//  PlayerWithFlagNode.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import SceneKit

func newPlayerWithFlagNode(team: Team) -> SCNNode {
    
    // Declaring the Nodes
    var playerWithFlag = SCNNode()
    var player = newPlayerNode(team: team)
    var flag = newFlagNode(team: team == .red ? .blue : .red)

    
    // Position
    flag.position = SCNVector3(0.25, 0, 0)
    player.position = SCNVector3(0, 0, 0)
    
    playerWithFlag.addChildNode(flag)
    playerWithFlag.addChildNode(player)
    
    return playerWithFlag
}
