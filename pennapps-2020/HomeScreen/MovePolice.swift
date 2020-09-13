//
//  MovePolice.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class MovePolice {
    
    static func isOutOfBounds(x: CGFloat, z: CGFloat, team: Team) -> Bool {
        
        let newX = (x + COURT_WIDTH / 2)
        let outOfBoundsXAxis = newX < 0 || newX > COURT_WIDTH
        
        var outOfBoundsZAxis = false
        
        if team == .red {
            outOfBoundsZAxis = z <= -COURT_LENGTH / 2 || z >= (COURT_LENGTH / 2) + SAFE_ZONE_LENGTH
        } else {
            outOfBoundsZAxis = z <= -(COURT_LENGTH / 2) - SAFE_ZONE_LENGTH  || z >=  COURT_LENGTH / 2
        }
        
        return outOfBoundsZAxis || outOfBoundsXAxis
    }
    
    
    
    static func isSafe(x: CGFloat, z: CGFloat, team: Team) -> Bool {
        
        // If out of bounds, then you are not safe
        guard !isOutOfBounds(x: x, z: z, team: team) else { return false }
        
            
        let inSafeArea = team == .red ? z > COURT_LENGTH / 2 : z < -COURT_LENGTH - 2
        let inOwnArea = team == .red ? z < 0 : z > 0
        
        return inSafeArea || inOwnArea
        
    }
    
    // Tells whether or not a player is in bounds
    static func isInPlay(id: String) -> Bool {
        // TODO: write some code with the Firebase shit idk loll
        return false
    }
    
    // Function that checks whether p1 could have tagged p2
    static func isValidTag(p1X: Float, p1Z: Float, p2X: Float, p2Z: Float, p1Team: Team, p2Team: Team) -> Bool {
        
        // If player one is out of bounds, invalid tag
        if isOutOfBounds(x: CGFloat(p1X), z: CGFloat(p1Z), team: p1Team) { return false }
        
        // If player two is safe invalid tag
        if isSafe(x: CGFloat(p2X), z: CGFloat(p2Z), team: p2Team) { return false }
        
        // At this point, player one is in bounds and player two isn't safe
        return true
    }
}
