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

    @IBAction func login(_ sender: Any) {
        signIn()
        
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "startScreen") as! StartScreenViewController
//        self.present(vc, animated: true, completion: nil)
        
    }
    
    func signIn()
    {
        let email = emailField.text! as String
        let password = passwordField.text! as String
        
        if let current = Auth.auth().currentUser
        {
            //TODO: Check if user is already signed in - no
            
            
         self.dismiss(animated: true, completion: nil)
        }
        else
        {
    
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            //successfully logged in our user
            self.dismiss(animated: true, completion: nil)
            
            })
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}



