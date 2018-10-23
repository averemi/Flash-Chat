//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase


class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
        
            Auth.auth().createUser(withEmail: email, password: password) { (userInfo, error) in
                if let err = error {
                    print(err)
                }
                else {
                    print("Registration Successful")
                    
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        }
        
        //TODO: Set up a new user on our Firbase database
        
        

        
        
    } 
    
    
}
