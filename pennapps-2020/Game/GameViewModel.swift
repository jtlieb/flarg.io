//
//  GameViewModel.swift
//  pennapps-2020
//
//  Created by Alexander Go on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import Firebase
import SceneKit

class GameViewModel {
    var PLAY_ROOMS_DB: String = "flag_rooms"
    var ref: DatabaseReference!
    var ROOM_ID: String
    var userId: String!
    var hostId: String!
    var gamePlayers: [String : GamePlayer]!
    var redFlagAvailable: Bool!
    var blueFlagAvailable: Bool!

    let TAGGABLE_RADIUS = 0.7

    
    init(roomId: String, ref: DatabaseReference!, userId: String, hostId: String, gamePlayers: [String : GamePlayer]) {
        self.ROOM_ID = roomId
        self.ref = ref
        self.userId = userId
        self.hostId = hostId
        self.gamePlayers = gamePlayers
        self.redFlagAvailable = true
        self.blueFlagAvailable = true
    }
    
    func getGamePlayers() -> [String: GamePlayer] {
        return gamePlayers
    }
    
    // sending x-z coordinates to database
    func updatePosition(userId: String, x: Double, z: Double, handler: @escaping (Error?) -> Void) {
    //        let players: [String: String] = [userId:nickname]
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/\(userId)/x").setValue(x)
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/\(userId)/z").setValue(z)
    }
    
    func observeFlagAvailability(flagString: String, handler: @escaping (String?, Bool?) -> Void) {
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/\(flagString)/").observe(.value) { (snapshot) in
            guard let flagAvailable = snapshot.value as? Bool else {
                handler("flag available was not boolean", nil)
                return
            }
            
            handler(nil, flagAvailable)
        }
    }
    
    func observeGamePlayers(handler: @escaping (String?) -> Void) {
        let newRef = ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/")
        newRef.observe(.childChanged) {(snapshot) in
//            print(snapshot.key)
            let newPlayer = newRef.child(snapshot.key)
//            print(snapshot.value)
            
            guard let data = snapshot.value as? [String : Any] else {
                handler("game player has wrong type")
                return
            }
            
            let userId = snapshot.key
            
            let nickname = data["nickname"] as! String
            let team = data["team"] as! Int
            let active = data["active"] as! Bool
            let hasFlag = data["hasFlag"] as! Bool
            let x = data["x"] as! Double
            let z = data["z"] as! Double
            let gamePlayer = GamePlayer(userId: userId, nickname: nickname, team: team, active: active, x: x, z: z, hasFlag: hasFlag, node: newPlayerNode(team: team == 0 ? .red : .blue))
            
            self.gamePlayers[userId] = gamePlayer
            
            handler(nil)
            
//            self.gamePlayers[snapshot.key] = GamePlayer(userId: snapshot.key, nickname: (newPlayer.child("nickname")), team: newPlayer.child("team"), active: newPlayer.child("active"), x: newPlayer.child("x"), z: newPlayer.child("z"), hasFlag: newPlayer.child("hasFlag"))
//            print(newPlayer.child("active"))
        }
    }
    
    func observeActiveStatus(handler: @escaping (String?, String?) -> Void) {
        
        ref.child(PLAY_ROOMS_DB).child(ROOM_ID).child("players").child(userId).child("active").observe(.value) { (snapshot) in
            
            print("observing active status")
            guard let active = snapshot.value as? Bool else {
                handler("active status was not boolean", nil)
                return
            }
            
            print("active: \(active)")
            print(active)
            
            if active {
                handler(nil, "You are now active!")
            } else {
                handler(nil, "You have been tagged!")
                if (self.gamePlayers[self.userId]!.hasFlag) {
                    self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child("players").child(self.userId).child("hasFlag").setValue(false)
                }
            }
        }
    }
    
    // return true
    func resurrectPlayer() {
        var player = gamePlayers[userId]!
            if !player.active {
                if player.isInOwnTeamTerritory() {
                    var timeRemaining = 100
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (Timer) in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                            if !player.isInOwnTeamTerritory() {
                                return
                            }
                        } else {
                            Timer.invalidate()
                            self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child("players").child(self.userId).child("active").setValue(true)
//                            player.active = true
                        }
                    }
                }
            }
        }

}
