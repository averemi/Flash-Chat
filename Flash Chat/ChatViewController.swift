//
//  ViewController.swift
//  Flash Chat
//
//  Created by Anastasiia Veremiichyk on 23/10/2018.
//  Copyright © 2018 Anastasiia VEREMIICHYK. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    var messageDictionary : NSDictionary = [:]
    var messageArray : [Message] = [Message]()
    
 //   var keyboardHeight : CGFloat = 0.0

    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    /*    NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: Notification.Name.UIKeyboardDidShow,
            object: nil
        )
*/
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell // for each row the cell is custom
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
        
    }
    
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    func    configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50 + 295
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    /*
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            print(keyboardHeight)
        }
    }*/
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        if let message = messageTextfield.text {
            messageDictionary = ["Sender": Auth.auth().currentUser?.email as Any,
                                     "MessageBody": message]
        }
        
        messagesDB.childByAutoId() // this creates a custom message key for our messages; so each message gets saved by its unique identifier
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if let err = error {
                print(err)
            }
            else {
                print("Message saved successfully")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { // childAdded - means observing whenever the new message is added in our database
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            if let text = snapshotValue["MessageBody"], let sender = snapshotValue["Sender"] {
                let message = Message()
                message.messageBody = text
                message.sender = sender
                
                self.messageArray.append(message)
                
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            
      //      navigationController?.popToRootViewController(animated: true) // to take the user from the chat view controller to the welcome view controller
        }
        catch {
            print("error, there was a problem signing out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil else {
            print("No View Controllers to pop off")
            return
        }
    }
    

}
