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
    var isHost = false
    var roomId: String!
    
    private var lobbyPlayers : [LobbyPlayer] = []
    
    init(roomId: String, ref: DatabaseReference!, isHost: Bool) {
        self.ROOM_ID = roomId
        self.ref = ref
        self.isHost = isHost
    }
    
    func getLobbyPlayers() -> [LobbyPlayer] {
        return lobbyPlayers
    } 
    
    func addLobbyPlayer(lobbyPlayer: LobbyPlayer) {
        lobbyPlayers.append(lobbyPlayer)
    }
    
    func removeLobbyPlayer(lobbyPlayer: LobbyPlayer) {
        lobbyPlayers.removeAll { (player) -> Bool in
            player.userId == lobbyPlayer.userId
        }
        
        if (lobbyPlayers.count == 0) {
            // remove waiting room from database
        }
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
                playerRemovedHandler("added player's nickname wasn't String", nil)
                return
            }

            guard let team = data["team"] as? Int else {
                playerRemovedHandler("added player's team wasn't Int", nil)
                return
            }
            
            playerRemovedHandler(nil, LobbyPlayer(userId: snapshot.key, nickName: nickname, team: team))
        }
    }
}
