//
//  ViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 11/15/18.
//  Copyright © 2018 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StartScreenViewController: UIViewController {

    //Properties
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var pastRunsButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var sharedRunsButton: UIButton!
    @IBOutlet weak var newRunButton: UIButton!
    
    //Actions
    
    
    @IBAction func signOut(_ sender: Any) {
        try! Auth.auth().signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "openingViewController") as! OpeningViewController
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

