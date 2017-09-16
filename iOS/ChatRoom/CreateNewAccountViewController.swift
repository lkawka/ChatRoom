//
//  CreateNewAccountViewController.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 16/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

class CreateNewAccountViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    var orangeColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    
    var username: String = ""
    var password: String = ""
    var repeatPassword: String = ""
    
    @IBOutlet weak var newAccountLabel: UILabel!
    @IBOutlet weak var usernameTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var repeatPasswordTextField: MyTextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up textFields and buttons
        newAccountLabel.textColor = orangeColor
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        
        usernameTextField.placeholderText = "Username"
        passwordTextField.placeholderText = "Password"
        repeatPasswordTextField.placeholderText = "Repeat Password"
        
        createButton.backgroundColor = orangeColor
        createButton.layer.cornerRadius = 16.0
        createButton.setTitleColor(UIColor.white, for: .normal)
        
        backButton.setTitleColor(orangeColor, for: .normal)
        
        handleCreateButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Handling textFields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            repeatPasswordTextField.becomeFirstResponder()
        case repeatPasswordTextField:
            if(createButton.isEnabled) {
                //perform segue here
            }
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Dissmiss keyboard when touched outside textfield
        self.view.endEditing(true)
    }
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        handleCreateButton()
    }
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        handleCreateButton()
    }
    @IBAction func repeatPasswordTextFieldChanged(_ sender: Any) {
        handleCreateButton()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - Private functions

    private func handleCreateButton(){
        if(usernameTextField.text! != "" && passwordTextField.text! != "" && repeatPasswordTextField.text! != "") {
            createButton.isEnabled = true
            createButton.alpha = 1.0
        } else {
            createButton.isEnabled = false
            createButton.alpha = 0.7
        }
    }
    
    func createButtonTapped() {
        username = usernameTextField.text!
        password = usernameTextField.text!
        repeatPassword = repeatPasswordTextField.text!
    }
    
}

