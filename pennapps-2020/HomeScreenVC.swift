//
//  ViewController.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/11/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import UIKit
import Firebase

class HomeScreenVC: UIViewController {
    
    // On-Screen Components (buttons, labels, text boxes, etc)
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var roomIdField: UITextField!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    

    var evenNumJoinPressed = true
    
    
    // Model (data structures and stuff)
    // Firebase reference. Use to get data about rooms and update rooms
    var ref: DatabaseReference!
    var viewModel = HomeScreenViewModel()

    // Controller (all functions that manipulate the view and model
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
//        self.ref.child("users").child("userid").setValue(["username": "hi"])
        roomLabel.isHidden = true
        nicknameLabel.isHidden = true
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
        
        viewModel.joinWaitingRoom(ref: ref, roomId: roomId!, userId: UUID().uuidString, nickname: nickname!, handler: { errorMsg, dbRef in
            if (errorMsg != nil) {
                print(errorMsg)
            } else {
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
        
        viewModel.createWaitingRoom(ref: ref, userId: UUID().uuidString, nickname: nickname!, handler: { error, dbRef in
            if (error != nil) {
                print("Error creating room")
            } else {
                self.performSegue(withIdentifier: "create", sender: self)
            }
        })
        /** TODO:
            Segue to Lobby Screen
            Generate 6 Character Alphanumeric
         */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "join" {
            let vc = segue.destination as! JoinGroupVC
            vc.delegate = self
            return 
        }
    }
    


}

