//
//  LobbyViewModel.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import Firebase

class LobbyViewModel {
    
    private let WAITING_ROOMS_DB: String = "waiting_rooms"
    private let FLAG_ROOMS_DB: String = "flag_rooms"

    private let HOST_STARTED: String = "host_started"

    var ROOM_ID: String
    
    var ref: DatabaseReference!
    var userId: String!
    var hostId: String!
    
    private var lobbyPlayers: [LobbyPlayer] = []
    private var playersSuccessfullyLaunched = 0
    private var gamePlayers: [GamePlayer] = []
    
    init(roomId: String, ref: DatabaseReference!, userId: String, hostId: String) {
        self.ROOM_ID = roomId
        self.ref = ref
        self.userId = userId
        self.hostId = hostId
    }
    
    func isEmpty() -> Bool {
        return lobbyPlayers.count == 0
    }
    
    func isHost() -> Bool {
        return userId == hostId
    }
    
    func getTeam(team: Int) -> [LobbyPlayer] {
        return lobbyPlayers.filter { (lobbyPlayer) -> Bool in
            lobbyPlayer.team == team
        }
    }
    
    func addLobbyPlayer(lobbyPlayer: LobbyPlayer) {
        lobbyPlayers.append(lobbyPlayer)
    }
    
    func removeLobbyPlayer(userId: String) {
        lobbyPlayers.removeAll { (lobbyPlayer) -> Bool in
            lobbyPlayer.userId == userId
        }
    }
    
    func observeGameLaunchedComplete(handler: @escaping (String?, Bool?) -> Void) {
        ref.child(FLAG_ROOMS_DB).child(ROOM_ID).child("players").observe(.childAdded) { (snapshot) in
//            print("new person launched")
//            print(snapshot)
            guard let data = snapshot.value as? [String: Any] else {
                handler("player added was invalid", nil)
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
            
            self.gamePlayers.append(gamePlayer)
            handler(nil, self.gamePlayers.count == self.lobbyPlayers.count)
        }
        
    }
    
    func observeGameLaunched(handler: @escaping (String?, Bool?) -> Void) {
        print("observing game start")
        let host_started_ref = ref.child(WAITING_ROOMS_DB).child(ROOM_ID).child(HOST_STARTED)
        host_started_ref.observe(.value) { (snapshot) in
            print("host started game")
            guard let data = snapshot.value as? Bool else {
                handler("started game var was not boolean", nil)
                return
            }
                
            handler(nil, data)
        }
    }
    
    func observePlayers(playerAddedHandler: @escaping ((String?, LobbyPlayer?) -> Void), playerRemovedHandler: @escaping ((String?, LobbyPlayer?) -> Void)) {
                
        let roomRef = ref.child(WAITING_ROOMS_DB).child(ROOM_ID)
        
        roomRef.observe(.childAdded) { (snapshot) in
            print("child added")

            guard let data = snapshot.value as? [String: Any] else {
                playerAddedHandler("player added was invalid", nil)
                return
            }
            
            guard let nickname = data["nickname"] as? String else {
                playerAddedHandler("added player's nickname wasn't String", nil)
                return
            }

            guard let team = data["team"] as? Int else {
                playerAddedHandler("added player's team wasn't Int", nil)
                return
            }
            
            playerAddedHandler(nil, LobbyPlayer(userId: snapshot.key, nickName: nickname, team: team))
        }
        
        roomRef.observe(.childRemoved) { (snapshot) in
            print("observing removing child...")
            guard let data = snapshot.value as? [String: Any] else {
                playerRemovedHandler("player removed is invalid", nil)
                return
            }
            
            guard let nickname = data["nickname"] as? String else {
                playerRemovedHandler("removed player's nickname wasn't String", nil)
                return
            }

            guard let team = data["team"] as? Int else {
                playerRemovedHandler("removed player's team wasn't Int", nil)
                return
            }
            
            playerRemovedHandler(nil, LobbyPlayer(userId: snapshot.key, nickName: nickname, team: team))
        }
    }
    
    func exitRoom(handler: @escaping (Error?) -> Void) {
        print(userId + " is exiting room")
        ref.child(WAITING_ROOMS_DB).child(ROOM_ID).child(userId).removeValue { (error, dbRef) in
            if self.isHost() {
                self.ref.child(self.WAITING_ROOMS_DB).child(self.ROOM_ID).child("host").removeValue()
            }
            handler(error)
        }
    }
    
    func eraseRoom(handler: @escaping (Error?) -> Void) {
        print("remove room ")
        ref.child(WAITING_ROOMS_DB).child(ROOM_ID).removeValue { (error, dbRef) in
            handler(error)
        }
    }
    
    func startRoom(handler: @escaping (String?, GamePlayer?) -> Void) {
        if (!isHost()) {
            handler("Only the host can start the room", nil)
            return
        }
        
        var lobbyPlayer: LobbyPlayer? = nil
        for l in lobbyPlayers {
            if l.userId == userId {
                lobbyPlayer = l
            }
        }
        
        if (lobbyPlayer == nil) {
            handler("couldn't find lobby player for userId", nil)
            return
        }
        
        let gamePlayer = GamePlayer(userId: lobbyPlayer!.userId, nickname: lobbyPlayer!.nickName, team: lobbyPlayer!.team, active: true, x: 0, z: 0, hasFlag: false, node: newPlayerNode(team: lobbyPlayer!.team == 0 ? .red : .blue))
        let data: [String: Any] = ["players": [gamePlayer.userId: ["nickname": gamePlayer.nickname, "team": gamePlayer.team, "active": gamePlayer.active, "x": gamePlayer.x, "z": gamePlayer.z, "hasFlag": gamePlayer.hasFlag]]]
        ref.child(FLAG_ROOMS_DB).child(ROOM_ID).setValue(data) { (error, dbRef) in
            if error != nil {
                handler(error?.localizedDescription, nil)
            } else {
                handler(nil, gamePlayer)
            }
        }
        
    }
    
    func changeHostStartedRoomStatus(handler: @escaping (Error?) -> Void) {
        print("changing host started room status")
        ref.child(WAITING_ROOMS_DB).child(ROOM_ID).child(HOST_STARTED).setValue(true) { (error, dbRef) in
            handler(error)
        }
        
    }
    
    func joinStartedRoom(handler: @escaping (String?, GamePlayer?) -> Void) {
        print("joining started room (NEEDS IMPL)")
        
        var lobbyPlayer: LobbyPlayer? = nil
        for l in lobbyPlayers {
            if l.userId == userId {
                lobbyPlayer = l
            }
        }
        
        if (lobbyPlayer == nil) {
            handler("couldn't find lobby player for userId", nil)
            return
        }
        
        let gamePlayer = GamePlayer(userId: lobbyPlayer!.userId, nickname: lobbyPlayer!.nickName, team: lobbyPlayer!.team, active: true, x: 0, z: 0, hasFlag: false, node: newPlayerNode(team: lobbyPlayer!.team == 0 ? .red : .blue))
        let data: [String: Any] =  ["nickname": gamePlayer.nickname, "team": gamePlayer.team, "active": gamePlayer.active, "x": gamePlayer.x, "z": gamePlayer.z, "hasFlag": gamePlayer.hasFlag]
        
        ref.child(FLAG_ROOMS_DB).child(ROOM_ID).child("players").child(userId).setValue(data) { (error, dbRef) in
            if (error != nil) {
                handler(error?.localizedDescription, nil)
            } else {
                handler(nil, gamePlayer)
            }
        }
    }
    
    func getGamePlayers() -> [GamePlayer] {
        return gamePlayers
    }
}
