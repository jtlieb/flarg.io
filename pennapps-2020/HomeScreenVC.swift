//
//  ViewController.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/11/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import UIKit
import Firebase

class HomeScreenVC: UIViewController, UITextFieldDelegate {
    
    // On-Screen Components (buttons, labels, text boxes, etc)
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var roomIdField: UITextField!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    

    var evenNumJoinPressed = true
    
    var roomId = ""
    
    // Model (data structures and stuff)
    // Firebase reference. Use to get data about rooms and update rooms
    var viewModel: HomeScreenViewModel!

    // Controller (all functions that manipulate the view and model
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel = HomeScreenViewModel(ref: Database.database().reference())

        roomLabel.isHidden = true
        nicknameLabel.isHidden = true
        nicknameTextField.delegate = self
        roomIdField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nicknameTextField.resignFirstResponder()
        roomIdField.resignFirstResponder()
        return true
    }
    
    @IBAction func joinPressed(sender: Any) {
        
        let roomId = roomIdField.text
        if (!viewModel.checkNotEmptyOrNull(s: roomId!)) {
            print("Invalid roomId")
            roomLabel.isHidden = false
            return
        } else {
            roomLabel.isHidden = true
        }
        // TODO: Segue to the Join Screen\
        let nickname = nicknameTextField.text
        if (!viewModel.checkNotEmptyOrNull(s: nickname!)) {
            print("Invalid nickname")
            nicknameLabel.isHidden = false
            return
        } else {
            nicknameLabel.isHidden = true
        }
        
        
        viewModel.joinWaitingRoom(roomId: roomId!, userId: UUID().uuidString, nickname: nickname!, handler: { errorMsg, dbRef in
            if (errorMsg != nil) {
                self.notifyUser(title: "Error", message: "A room with this ID does not exist")
            } else {
                self.roomId = roomId!
                self.roomLabel.isHidden = true
                self.nicknameLabel.isHidden = true

                self.performSegue(withIdentifier: "join", sender: self)
            }
        })
    }
    
    
    @IBAction func createPressed(sender: Any) {
        print("Create Pressed")
        
        let nickname = nicknameTextField.text
        if (!viewModel.checkNotEmptyOrNull(s: nickname!)) {
            print("Invalid nickname")
            return
        }
        
        viewModel.createWaitingRoom(userId: UUID().uuidString, nickname: nickname!, handler: { error, roomId in
            if (error != nil) {
                self.notifyUser(title: "Error", message: "There was an error creating this room")
            } else {
                print("Successfully created room" + roomId)
                self.roomId = roomId
                self.performSegue(withIdentifier: "create", sender: self)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! LobbyVC
        vc.delegate = self
        vc.viewModel = LobbyViewModel(roomId: self.roomId, ref: viewModel.ref, isHost: segue.identifier == "create")
    }
    
    func notifyUser(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)

        let cancelAction = UIAlertAction(title: "OK",
            style: .cancel, handler: nil)

        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }

}

