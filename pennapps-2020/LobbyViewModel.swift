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
    
    var ROOM_ID: String
    
    init(roomId: String) {
        self.ROOM_ID = roomId
    }
    
    func observePlayers(ref: DatabaseReference, handler: ((String?, [LobbyPlayer]) -> Void)) {
        ref.child("messages").observe(.childChanged) { (snapshot, key) in
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
