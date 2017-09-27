//
//  LogInViewController.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 07/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    var host = "127.0.0.1"
    var port: UInt32 = 9997
    
    var username: String = ""
    var password: String = ""
    
    var orangeColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    var grayColor = UIColor(red:0.58, green:0.60, blue:0.60, alpha:1.0)
    
    @IBOutlet weak var usernameTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var passwordReminderButton: UIButton!
    @IBOutlet weak var createNewAccountButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    var serverConnection = ServerConnection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.placeholderText = "Username"
        passwordTextField.placeholderText = "Password"
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        logInButton.backgroundColor = orangeColor
        logInButton.layer.cornerRadius = 16.0
        logInButton.setTitleColor(UIColor.white, for: .normal)
        
        handleLogInButton()
        
        passwordReminderButton.setTitleColor(orangeColor, for: .normal)
        createNewAccountButton.setTitleColor(orangeColor, for: .normal)
        
        refreshButton.setTitleColor(orangeColor, for: .normal)
        refreshButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        serverConnection.delegate = self
        serverConnection.setUpNetworkConnection(host: self.host, port: self.port)
    }
    
    //MARK: - Handling textFields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            if(logInButton.isEnabled == true) {
                logInButtonTapped(button: logInButton)
            }
        }
       
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier ?? "" {
        case "enterChatRoom":
            
            guard let chatRoom = segue.destination as? ChatRoomViewController else {
                fatalError("ChatRoom did not load")
            }
            
            chatRoom.username = username
            chatRoom.serverConnection = self.serverConnection
        case "createNewAccount":
            //do something here                         <---------- DO STH HERE LATER
            break
        default:
            fatalError("Unexpected destination")
        }
    }
 
    
    //MARK: - Buttons' actions
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        serverConnection.stop()
        serverConnection.setUpNetworkConnection(host: host, port: port)
    }
    
    @IBAction func usernameTextFieldChanged(_ sender: MyTextField) {
        handleLogInButton()
    }
    @IBAction func passwordTextFieldChanged(_ sender: MyTextField) {
        handleLogInButton()
    }
    
    private func handleLogInButton() {
        
        if(usernameTextField.text! != "" && passwordTextField.text! != "") {
            
            logInButton.isEnabled = true
            logInButton.alpha = 1.0
            passwordTextField.enablesReturnKeyAutomatically = true
        } else {
            
            logInButton.isEnabled = false
            logInButton.alpha = 0.75
            passwordTextField.enablesReturnKeyAutomatically = false
        }
    }
    
    func logInButtonTapped(button: UIButton) {
        username = usernameTextField.text!
        password = passwordTextField.text!
        
        let logInRequest = "LOG" + String(format: "%02d", username.count) + username + String(format: "%02d", password.count) + password
        
        serverConnection.sendData(logInRequest)
        
        self.view.endEditing(true)
    }
    
    func clearTextFields() {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
}
extension LogInViewController: ServerConnectionDelegate {
    func receivedData(_ text: String) {
        print("LogInViewController received \(text)")
        
        if(text == "DIDNOTCONNECT") {
            refreshButton.isHidden = false
            
            print("Did not connect to the server")
        } else if (text == "DIDCONNECT") {
            refreshButton.isHidden = true
            
            print("Successfully connected to the server")
        } else if (text.subString(0, 4) == "LOG0") {
            print("wrong username or password")
            
            clearTextFields()
        } else if (text.subString(0, 4) == "LOG1") {
            performSegue(withIdentifier: "enterChatRoom", sender: nil)
        }
    }
}
