//
//  GameViewModel.swift
//  pennapps-2020
//
//  Created by Alexander Go on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import Firebase

class GameViewModel {
    var PLAY_ROOMS_DB: String = "flag_rooms"
    
    var ref: DatabaseReference!
    var ROOM_ID: String
    var userId: String!
    var hostId: String!
    var gamePlayers: [GamePlayer]!
    
    init(roomId: String, ref: DatabaseReference!, userId: String, hostId: String, gamePlayers: [GamePlayer]) {
        self.ROOM_ID = roomId
        self.ref = ref
        self.userId = userId
        self.hostId = hostId
        self.gamePlayers = gamePlayers
    }
    
    // sending x-z coordinates to database
    func updatePosition(userId: String, x: Double, z: Double, handler: @escaping (Error?) -> Void) {
    //        let players: [String: String] = [userId:nickname]
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/\(userId)/x").setValue(x)
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/\(userId)/z").setValue(z)
    }
    
    func observeGamePlayers(handler: @escaping (Error?) -> Void) {
        print("Observer Game Playersss-------------")
        print(hostId)
        ref.child("\(self.PLAY_ROOMS_DB)/\(self.ROOM_ID)/players/\(String(describing: hostId))").observe(.childChanged) {(snapshot) in
            print("observeGamePlayers")
            print(snapshot)
        }
    }
}
