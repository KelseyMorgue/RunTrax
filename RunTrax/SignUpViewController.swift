//
//  SignUpViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/1/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController:UIViewController, UITextFieldDelegate {

    
// Outlets
 @IBOutlet weak var usernameField: UITextField!
 @IBOutlet weak var emailField: UITextField!
 @IBOutlet weak var passwordField: UITextField!
 @IBOutlet weak var profileImageView: UIImageView!
 @IBOutlet weak var tapToChangeProfileButton: UIButton!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}
