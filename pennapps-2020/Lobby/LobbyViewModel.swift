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
    var ROOM_ID: String
    
    var ref: DatabaseReference!
    var userId: String!
    var hostId: String!
    
    private var lobbyPlayers: [LobbyPlayer] = []
    
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
    
    func observeGameStart() {
        let roomRef = ref.child(WAITING_ROOMS_DB).child(ROOM_ID)
    }
    
    func observePlayers(playerAddedHandler: @escaping ((String?, LobbyPlayer?) -> Void), playerRemovedHandler: @escaping ((String?, LobbyPlayer?) -> Void)) {
                
        let roomRef = ref.child(WAITING_ROOMS_DB).child(ROOM_ID)
        print(roomRef)
        
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
}
