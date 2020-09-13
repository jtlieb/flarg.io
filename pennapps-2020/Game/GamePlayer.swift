//
//  GamePlayer.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import SceneKit

struct GamePlayer {
    var userId: String
    var nickname: String
    var team: Int
    var active: Bool
    var x: Double
    var z: Double
    var hasFlag: Bool
    var node: SCNNode
    
    func isOutOfBounds() -> Bool {
        
        var x = Float(self.x)
        var z = Float(self.z)
        
        let newX = (x + COURT_WIDTH / 2)
        let outOfBoundsXAxis = newX < 0 || newX > COURT_WIDTH
        
        var outOfBoundsZAxis = false
        
        if team == 0 {
            outOfBoundsZAxis = z <= -COURT_LENGTH / 2 || z >= (COURT_LENGTH / 2) + SAFE_ZONE_LENGTH
        } else {
            outOfBoundsZAxis = z <= -(COURT_LENGTH / 2) - SAFE_ZONE_LENGTH  || z >=  COURT_LENGTH / 2
        }
        
        return outOfBoundsZAxis || outOfBoundsXAxis
    }
    
    
    func isSafe() -> Bool {
        guard !isOutOfBounds() else { return false }
       
        var z = Float(self.z)
        
        let inSafeArea = self.team == 0 ? z > COURT_LENGTH / 2 : z < -COURT_LENGTH - 2
        let inOwnArea = self.team == 0 ? z < 0 : z > 0

        return inSafeArea || inOwnArea
    }
    
    func isValidTag(p2: GamePlayer) -> Bool {
        
        // Valid tag occurs when you're in bounds, other player is not safe,
        // and both are active
        return !self.isOutOfBounds() && !p2.isSafe() && self.active && p2.active
        
    }
    
    // You're in the flag zone when youre not out of bounds, you're safe, and
    // you're past the end of the other teams' zone
    func isInFlagZone() -> Bool {
        let z = Float(self.z)
        
        guard !isOutOfBounds() else { return false }
        guard isSafe() else { return false }
        
        if self.team == 0 {
            return z > COURT_LENGTH * 0.5
        } else {
            return z < -COURT_LENGTH * 0.5
        }
        
    }
    // In own territory when safe, not out of bounds
    func isInOwnTeamTerritory() -> Bool {
        let z = Float(self.z)
        
        guard !isOutOfBounds() else { return false }
        guard isSafe() else { return false }
        
        if self.team == 0 {
            return z > 0
        } else {
            return z < 0
        }
    }
}
