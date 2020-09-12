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
    @IBOutlet weak var startButton: UIButton!
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = "Room ID: \(self.delegate.roomId)"
        redTeamTable.delegate = self
        blueTeamTable.delegate = self
        
        redTeamTable.dataSource = self
        blueTeamTable.dataSource = self
        
        redTeamTable.register(LobbyPlayerTableViewCell.self, forCellReuseIdentifier: "cellId")
        blueTeamTable.register(LobbyPlayerTableViewCell.self, forCellReuseIdentifier: "cellId")
        
        self.viewModel.observeGameLaunchedComplete { (error, gameLaunched) in
            print("observingGameLaunched")
            if (gameLaunched != nil && gameLaunched!) {
                self.performSegue(withIdentifier: "start", sender: self)
            }
        }
        
        if !viewModel.isHost() {
            viewModel.observeGameLaunched { (error, gameStarted) in
                if error != nil {
                    print(error)
                } else {
                    self.viewModel.joinStartedRoom { (error, gamePlayer) in
                        
                    }
                }
            }
        }

        viewModel.observePlayers(playerAddedHandler: { (error, addedPlayer) in
            if (error != nil) {
                print(error)
            } else if (addedPlayer != nil) {
                self.viewModel.addLobbyPlayer(lobbyPlayer: addedPlayer!)
                self.reloadTables()
            }
        }) { (error, removedPlayer) in
            if error != nil {
                print(error)
            } else if (removedPlayer != nil) {
                self.viewModel.removeLobbyPlayer(userId: removedPlayer!.userId)
                if (self.viewModel.isEmpty()) {
                    self.leaveRoom()
                    if (!self.viewModel.isHost()) {
                        self.notifyUser(title: "Error", message: "Host has left and deleted this room")
                    }
                }
                self.reloadTables()
            }
        }
        self.startButton.isHidden = !self.viewModel.isHost()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            viewModel.exitRoom { (error) in
                if error != nil {
                    print("Error exiting waiting room")
                } else {
                    self.viewModel.removeLobbyPlayer(userId: self.viewModel.userId)
                    if self.viewModel.isHost() {
                        self.viewModel.eraseRoom { (error2) in
                            if error != nil {
                                print("Error deleting waiting room")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func startPressed(action: Any) {
        print("start pressed")
        viewModel.startRoom { (error, gamePlayer) in
            if error != nil {
                print(error)
            } else {
                print("room started")
                self.viewModel.changeHostStartedRoomStatus { (error) in
                    if error != nil {
                        print(error)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else { return }
        
        let vc = segue.destination as! GameVC
        vc.delegate = self
        vc.viewModel = GameViewModel(roomId: viewModel.ROOM_ID, ref: viewModel.ref, userId: viewModel.userId, hostId: viewModel.hostId, gamePlayers: viewModel.getGamePlayers())
    }
    
}
