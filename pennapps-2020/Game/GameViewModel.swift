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
    
    let TAGGABLE_RADIUS = 0.7

    
    init(roomId: String, ref: DatabaseReference!, userId: String, hostId: String, gamePlayers: [String : GamePlayer]) {
        self.ROOM_ID = roomId
        self.ref = ref
        self.userId = userId
        self.hostId = hostId
        self.gamePlayers = gamePlayers
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
}
