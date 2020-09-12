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
    
    init(roomId: String) {
        self.ROOM_ID = roomId
    }
    
    func observePlayers(ref: DatabaseReference, handler: @escaping ((String?, [LobbyPlayer]) -> Void)) {
        print("in observe players")
        print(ROOM_ID)
        
        if (ROOM_ID == nil || ROOM_ID == "") {
            print("room id was not valid")
            return
        }
        
        print("hi")
        
        let roomRef = ref.child(WAITING_ROOMS_DB).child(ROOM_ID)
        roomRef.observe(.childAdded) { (childSnapshot) in
            ref.child(self.WAITING_ROOMS_DB).child(self.ROOM_ID).observe(.childChanged) { (snapshot) in
                guard let data = snapshot.value as? [String: Any] else {
                    handler("Players in this waiting room are wrong type", [])
                    return
                }
                   
                for entry in data{
                    print(entry)
                }
            }
        }
    }
}
