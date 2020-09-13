//
//  GameActionLogic.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/13/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation

extension GameViewModel {
        
    func takeAction(handler: @escaping (String) -> Void) {
        var userGamePlayer: GamePlayer!
        for entry in gamePlayers {
            if entry.key == userId {
                userGamePlayer = entry.value
            }
        }
        
        if !userGamePlayer.active {
            handler("You can't perform actions while being inactive")
            return
        }
        
        if userGamePlayer.isInFlagZone() {
            captureFlag(userGamePlayer: userGamePlayer, handler: handler)
        } else {
            tagClosestOpponentInRadius(userGamePlayer: userGamePlayer, handler: handler)
        }
    }
    
    private func captureFlag(userGamePlayer: GamePlayer, handler: @escaping (String) -> Void) {
        ref.child(PLAY_ROOMS_DB).child(ROOM_ID).child("players").child(userGamePlayer.userId).child("hasFlag").setValue(true) { (error, dbRef) in
            if error != nil {
                handler("Failed to pick up the flag!")
            } else {
                handler("You are holding the flag!")
            }
        }
    }
    
    private func tagClosestOpponentInRadius(userGamePlayer: GamePlayer, handler: @escaping (String) -> Void) {
        
        let userTeam = userGamePlayer.team
        var minDist: Double = Double(INT_MAX)
        var closestOpponent: GamePlayer? = nil
        for entry in gamePlayers {
            let gamePlayer = entry.value
            if gamePlayer.team != userTeam  {
                let dist = userGamePlayer.radialDistanceFrom(otherGamePlayer: gamePlayer)
                if dist < minDist {
                    minDist = dist
                    closestOpponent = entry.value
                }
            }
        }
        
        if (closestOpponent == nil) {
            handler("There are no opponents within taggable distance")
            return
        }
        
        if minDist < TAGGABLE_RADIUS {
            ref.child(PLAY_ROOMS_DB).child(ROOM_ID).child("players").child(closestOpponent!.userId).child("active").setValue(false) { (error, dbRef) in
                if error != nil {
                    handler("Tag missed!")
                } else {
                    handler("\(closestOpponent!.nickname) was tagged!")
                }
            }
        } else {
            handler("There are no opponents within taggable distance")
        }
    }
    
}
