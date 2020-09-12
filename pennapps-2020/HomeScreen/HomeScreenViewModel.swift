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
    
    var ref: DatabaseReference!
    
    init(ref: DatabaseReference!) {
        self.ref = ref
    }
    
    // check if the nickname is valid. It can't be null or empty
    func checkNotEmptyOrNull(s: String?) -> Bool {
        if (s == nil || s == "") {
            return false
        }
        return true
    }
    
    // creating a waiting room
    func createWaitingRoom(userId: String, nickname: String, handler: @escaping (Error?, String) -> Void) {
        var roomId: String = String.random()
    
        while(checkIfRoomExists(roomId: roomId)) {
            roomId = String.random()
        }
        let players = ["host": userId, "host_started": false, userId : ["nickname" : nickname, "team": 0]] as [String : Any]
//        let players: [String: String] = [userId:nickname]
        ref.child(WAITING_ROOMS_DB).child(roomId).setValue(players) { (error, dbRef) in
            
            handler(error, roomId)
            return
        }
    }
    
    // TODO: THIS DOESN'T WORK
    // check if the string roomId already exists in the waiting room database
    private func checkIfRoomExists(roomId: String) -> Bool {
        var exists = false
        ref.child(WAITING_ROOMS_DB + "/" + roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            exists = snapshot.exists()
        })
        return exists
    }
    
    // joining a waiting room
    func joinWaitingRoom(roomId: String, userId: String, nickname: String, handler: @escaping (String?, String, String?) -> Void) {
//        if (!checkIfRoomExists(ref: ref, roomId: roomId)) {
//            handler("waiting room does not exist", roomId)
//        }
        
        ref.child(WAITING_ROOMS_DB).child(roomId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? [String: Any] else {
                handler("Players in this waiting room are wrong type", roomId, nil)
                return
            }
            
            guard let hostId = data["host"] as? String else {
                handler("Players in this waiting room are wrong type", roomId, nil)
                return
            }
            
            let numPlayers = data.count - 1
            if (numPlayers == self.MAX_PARTICIPANTS) {
                handler("The maximum number of participants has been met", roomId, nil)
                return
            }
            
            var newData = data
            var team = 0
            print(numPlayers)
            if (numPlayers % 2 == 0) { team = 1 }
            newData[userId] = ["nickname" : nickname, "team": team]
            self.ref.child(self.WAITING_ROOMS_DB).child(roomId).setValue(newData) { (error, dbRef) in
                handler(error?.localizedDescription, roomId, hostId)
                return
            }
        }
    }
}
