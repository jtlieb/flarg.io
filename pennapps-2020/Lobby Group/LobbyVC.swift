//
//  LobbyVC.swift
//  pennapps-2020
//
//  Created by Justin Lieb on 9/12/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LobbyVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var redTeamTable: UITableView!
    @IBOutlet weak var blueTeamTable: UITableView!
    
    var ref: DatabaseReference!
    var delegate: HomeScreenVC!
    var isHost = false
    var roomId: String!
    var viewModel: LobbyViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.observePlayers(ref: ref) { (error, lobbyPlayers) in
            if (error != nil) {
                print(error)
            } else {
                print(lobbyPlayers)
            }
        }
    }
    
}
