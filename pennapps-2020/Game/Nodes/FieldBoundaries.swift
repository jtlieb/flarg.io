//
//  FieldBoundaries.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import SceneKit

let COURT_LENGTH: CGFloat = 10
let COURT_WIDTH: CGFloat = 5

func buildField() -> SCNNode {
    
    
    let field = SCNNode()
    
    // Red Court Lines
    let backRed = newLine(team: .red, isBackLine: true, length: COURT_WIDTH)
    let leftRed = newLine(team: .red, isBackLine: false, length: COURT_LENGTH / 2)
    let rightRed = newLine(team: .red, isBackLine: false, length: COURT_LENGTH / 2)
    
    // Blue Court Lines
    let backBlue = newLine(team: .blue, isBackLine: true, length: COURT_WIDTH)
    let leftBlue = newLine(team: .blue, isBackLine: false, length: COURT_LENGTH / 2)
    let rightBlue = newLine(team: .blue, isBackLine: false, length: COURT_LENGTH / 2)
    
    // Neutral Lines
    let middleLine = newLine(team: nil, isBackLine: true, length: COURT_WIDTH)
    
    let nodes = [backRed, leftRed, rightRed, backBlue, leftBlue, rightBlue, middleLine]
    
    backRed.position = SCNVector3(0, 0, -0.5 * COURT_LENGTH)
    leftRed.position = SCNVector3(-0.5 * COURT_WIDTH, 0, -0.25 * COURT_LENGTH)
    rightRed.position = SCNVector3(0.5 * COURT_WIDTH, 0, -0.25 * COURT_LENGTH)
    
    backBlue.position = SCNVector3(0, 0, 0.5 * COURT_LENGTH)
    leftBlue.position = SCNVector3(-0.5 * COURT_WIDTH, 0, 0.25 * COURT_LENGTH)
    rightBlue.position = SCNVector3(0.5 * COURT_WIDTH, 0, 0.25 * COURT_LENGTH)
    
    middleLine.position = SCNVector3(0, 0, 0)
    
    for node in nodes {
        field.addChildNode(node)
    }
    
    field.position = SCNVector3(0, -1.5, 0)
    
    
    return field
    
    
    
}

func newLine(team: Team?, isBackLine: Bool, length: CGFloat) -> SCNNode {
    
    let line = SCNNode()
    let width = isBackLine ? length : 0.1
    let lengthParam = isBackLine ? 0.1 : length
    line.geometry = SCNBox(width: width , height: 0.1, length: lengthParam, chamferRadius: 0)
    
    guard let team = team else {
        line.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        return line
    }
    
    line.geometry?.firstMaterial?.diffuse.contents = team == .red ? UIColor.red : UIColor.blue
    
    
    return line
    
}

