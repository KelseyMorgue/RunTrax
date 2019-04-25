//
//  LoginViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/1/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class LoginViewController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //Makes the keyboard dismiss when return is hit
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    //button
    @IBAction func login(_ sender: Any) {
        signIn()
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
        
        
    }
    
    //takes information from user to check and open that user's app
    func signIn()
    {
        let email = emailField.text! as String
        let password = passwordField.text! as String
        
        if let current = Auth.auth().currentUser
        {
            
            
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if error != nil
                {
                    print("login errrrrrrrr")
                    print(error?.localizedDescription)
                }
                
                if let loginFail = error {
                    print(loginFail)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
                
            })
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}



