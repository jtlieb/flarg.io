//
//  HomeScreenViewModel.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/11/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import Firebase

class HomeScreenViewModel {
    
    private let WAITING_ROOMS_DB: String = "waiting_rooms"
    private let MAX_PARTICIPANTS: Int = 20
    
    // check if the nickname is valid. It can't be null or empty
    func checkIfNicknameValid(nickname: String?) -> Bool {
        if (nickname == nil || nickname == "") {
            return false
        }
        return true
    }
    
    // creating a waiting room
    func createWaitingRoom(ref: DatabaseReference, userId: String, nickname: String, handler: @escaping (Error?, String) -> Void) {
        var roomId: String = String.random()
    
        while(checkIfRoomExists(ref: ref, roomId: roomId)) {
            roomId = String.random()
        }
        let players: [String: Any] = [userId:nickname]
        ref.child(WAITING_ROOMS_DB).child(roomId).setValue(players) { (error, dbRef) in
            handler(error, roomId)
            return
        }
    }
    
    // TODO: THIS DOESN'T WORK
    // check if the string roomId already exists in the waiting room database
    private func checkIfRoomExists(ref: DatabaseReference, roomId: String) -> Bool {
        var exists = false
        ref.child(WAITING_ROOMS_DB + "/" + roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            exists = snapshot.exists()
        })
        return exists
    }
    
    // joining a waiting room
    func joinWaitingRoom(ref: DatabaseReference, roomId: String, userId: String, nickname: String, handler: @escaping (String?, String) -> Void) {
        if (!checkIfRoomExists(ref: ref, roomId: roomId)) {
            handler("waiting room does not exist", roomId)
        }
        
        ref.child(WAITING_ROOMS_DB).child(roomId).observeSingleEvent(of: .value) { (snapshot) in
            guard let players = snapshot.value as? [String: String] else {
                handler("Players in this waiting room are wrong type", roomId)
                return
            }
            
            if (players.count == self.MAX_PARTICIPANTS) {
                handler("The maximum number of participants has been met", roomId)
                return
            }
            
            var newPlayers = players
            newPlayers[userId] = nickname
            ref.child(self.WAITING_ROOMS_DB).child(roomId).setValue(newPlayers) { (error, dbRef) in
                handler(error?.localizedDescription, roomId)
                return
            }
        }
    }
}
