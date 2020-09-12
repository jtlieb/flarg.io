//
//  ViewController.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/11/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
//        self.ref.child("users").child("userid").setValue(["username": "hi"])
    }


}

