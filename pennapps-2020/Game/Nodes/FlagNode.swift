//
//  FlagNode.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import SceneKit

enum Team {
    case red
    case blue
}

func newFlagNode(team: Team) -> SCNNode {
    
    let flag = SCNNode()
    let flaggyBoi = SCNNode()
    let flagPole = SCNNode()
    
    flaggyBoi.geometry = SCNBox(width: 0.75, height: 0.5, length: 0.05, chamferRadius: 0)
    flaggyBoi.geometry?.firstMaterial?.diffuse.contents = team == .red ? UIColor.red : UIColor.blue
    flaggyBoi.position = SCNVector3(0.375, 0.75, 0)
    flagPole.geometry = SCNBox(width: 0.1, height: 2, length: 0.1, chamferRadius: 0)
    flagPole.geometry?.firstMaterial?.diffuse.contents = team == .red ? UIColor.red : UIColor.blue
    flagPole.position = SCNVector3(0, 0, 0)
    
    flag.addChildNode(flagPole)
    flag.addChildNode(flaggyBoi)
    
    return flag
}
