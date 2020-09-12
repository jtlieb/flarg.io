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

class LobbyVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var redTeamTable: UITableView!
    @IBOutlet weak var blueTeamTable: UITableView!
    
    var delegate: HomeScreenVC!
    var viewModel: LobbyViewModel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getTeam(team: tableView.tag).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let team = viewModel.getTeam(team: tableView.tag)
        let user = team[indexPath.item]
        cell.textLabel?.text = user.nickName + (user.userId == viewModel.hostId ? " (host)" : "")
        return cell
    }
    
    private func reloadTables() {
        self.redTeamTable.reloadData()
        self.blueTeamTable.reloadData()
    }
    
    func leaveRoom() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redTeamTable.delegate = self
        blueTeamTable.delegate = self
        
        redTeamTable.dataSource = self
        blueTeamTable.dataSource = self
        
        redTeamTable.register(LobbyPlayerTableViewCell.self, forCellReuseIdentifier: "cellId")
        blueTeamTable.register(LobbyPlayerTableViewCell.self, forCellReuseIdentifier: "cellId")

        viewModel.observePlayers(playerAddedHandler: { (error, addedPlayer) in
            if (error != nil) {
                print(error)
            } else if (addedPlayer != nil) {
                self.viewModel.addLobbyPlayer(lobbyPlayer: addedPlayer!)
                self.reloadTables()
            }
        }) { (error, removedPlayer) in
            if (error != nil) {
                print(error)
            } else if (removedPlayer != nil) {
                self.viewModel.removeLobbyPlayer(userId: removedPlayer!.userId, { roomRemoved in
                    if (roomRemoved) {
                        self.notifyUser(title: "Error", message: "Host has left and deleted this room")
                        self.leaveRoom()
                    }
                })
                self.reloadTables()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            viewModel.exitLobby { (error, dbRef) in
                if (error != nil) {
                    print("Error exiting waiting room")
                } else {
                    self.viewModel.removeLobbyPlayer(userId: self.viewModel.userId, { _ in })
                    if (self.viewModel.isHost()) {
                        self.viewModel.deleteLobby { (error2, dbRef2) in
                            if (error != nil) {
                                print("Error deleting waiting room")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
