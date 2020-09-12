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
    
    var delegate: HomeScreenVC!
    var viewModel: LobbyViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.observePlayers(playerAddedHandler: { (error, addedPlayer) in
            if (error != nil) {
                print(error)
            } else if (addedPlayer != nil) {
                self.viewModel.addLobbyPlayer(lobbyPlayer: addedPlayer!)
                print(self.viewModel.getLobbyPlayers())
            }
        }) { (error, removedPlayer) in
            if (error != nil) {
                print(error)
            } else if (removedPlayer != nil) {
                self.viewModel.removeLobbyPlayer(lobbyPlayer: removedPlayer!)
                print(self.viewModel.getLobbyPlayers())
            }
        }
    }
    
}
