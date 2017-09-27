//
//  ChatRoomViewController.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 08/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit



class ChatRoomViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Properties
    
    //green, blue, purple, grey, red. teal, pink, idigo
    var colors = [UIColor(red:0.30, green:0.69, blue:0.31, alpha:0.9), UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0), UIColor(red:0.61, green:0.15, blue:0.69, alpha:0.9), UIColor(red:0.38, green:0.49, blue:0.55, alpha:0.9), UIColor(red:0.90, green:0.22, blue:0.21, alpha:0.9), UIColor(red:0.00, green:0.54, blue:0.48, alpha:0.9), UIColor(red:0.91, green:0.12, blue:0.39, alpha:0.9), UIColor(red:0.25, green:0.32, blue:0.71, alpha:0.9)]
    
    var assignedColor: [String: UIColor] = [:]
    
    var serverConnection: ServerConnection?
    
    var username: String = "ERROR"
    
    var alert: UIAlertController!
    
    var messages = [Message]()
    
    var orangeColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    var grayColor = UIColor(red:0.58, green:0.60, blue:0.60, alpha:1.0)
    var messageColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:0.85)

    
    var usernameLabel = UILabel()
    var menuButton = UIButton()
    
    var messageBoard = UITableView()
    
    var lowerBar = UIView()
    var messageTextField = UITextField()
    var sendButton = UIButton()
    
    let topMargin = UIApplication.shared.statusBarFrame.height + 4
    let sideMargin: CGFloat = 4
    var textWidth: CGFloat!
    var keyboardHeight: CGFloat!
    var lowerBarHeight: CGFloat = 40
    var tableViewHeight: CGFloat!
    var tableViewWidth: CGFloat!
    var messageWidth: CGFloat!
    var spaceBetweenCells: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loading ChatRoomViewController..")
        
        messageBoard.delegate = self
        messageBoard.dataSource = self
        
        //load messages from memeory
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: Message.ArchiveURL.path) as? [Message] {
            messages += array
        }
        
        //setting up observers for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide , object: nil)

        //Setting up main label
        usernameLabel.text = username
        self.view.addSubview(usernameLabel)
        
        messageBoard.separatorStyle = .none
        messageBoard.allowsSelection = false
        self.view.addSubview(messageBoard)
        
        menuButton.setTitle("Menu", for: .normal)
        menuButton.setTitleColor(orangeColor, for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(menuButton)
        
        //Setting up lowerBar
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(orangeColor, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        messageTextField.backgroundColor = grayColor
        messageTextField.delegate = self
        
        lowerBar.addSubview(sendButton)
        lowerBar.addSubview(messageTextField)
        self.view.addSubview(lowerBar)
        
        serverConnection?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let menuButtonSize = menuButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        menuButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width-sideMargin-menuButtonSize.width, y: topMargin), size: menuButtonSize)
        
        //improve later
        let usernameLabelSize = usernameLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        usernameLabel.frame = CGRect(origin: CGPoint(x: self.view.frame.midX-usernameLabelSize.width/2.0, y: topMargin), size: usernameLabelSize)
        
        tableViewWidth = self.view.frame.width-2*sideMargin
        tableViewHeight = self.view.frame.height-topMargin-menuButtonSize.height-5-lowerBarHeight
        
        lowerBar.frame = CGRect(x: sideMargin, y: self.view.frame.height - lowerBarHeight, width: tableViewWidth, height: lowerBarHeight)
        
        let sendButtonSize = sendButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        sendButton.frame = CGRect(origin: CGPoint(x: lowerBar.frame.width-sendButtonSize.width, y: 4), size: sendButtonSize)
        messageTextField.frame = CGRect(x: 0, y: 4, width: lowerBar.frame.width-sendButtonSize.width-5, height: lowerBarHeight-8)
        
        messageBoard.frame = CGRect(x: sideMargin, y: topMargin+menuButtonSize.height+5, width: tableViewWidth, height: tableViewHeight)
        
        messageWidth = 4*tableViewWidth/5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveToBottom(animate: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Handling table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageTableViewCell(style: .default, reuseIdentifier: "messageCell")
        let message = messages[indexPath.row]
        var shiftRight = false
        var backgroundColor = messageColor
        
        if(message.id == usernameLabel.text) {
            shiftRight = true
        } else {
            if(assignedColor[message.id] == nil) {
                assignedColor[message.id] = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            }
            backgroundColor = assignedColor[message.id]!
        }
        cell.setUp(message: message.text, width: messageWidth, shiftRight: shiftRight, color: backgroundColor, viewWidth: tableViewWidth)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row].text
        let label = UILabel()
        label.numberOfLines = 0
        label.text = message
        return label.sizeThatFits(CGSize(width: messageWidth, height: CGFloat.greatestFiniteMagnitude)).height + 4 + spaceBetweenCells
    }
    
    //MARK: - Handling buttons
    
    func menuButtonTapped(_ sender: Any) {
        //deleting all messages
        /*messages.removeAll()
        saveMessages()
        
        loadMessages()*/
        alert = UIAlertController(title: "Menu", message: "*Additional features*", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {action in
            self.logOut()
        })
        alert.addAction(logOutAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendButtonTapped() {
        if(messageTextField.text! != "") {
            let data = "MSG" + String(format: "%02d", username.count) + username + String(format: "%04d", messageTextField.text!.count) + messageTextField.text!
            if let _ = serverConnection {
                serverConnection?.sendData(data)
            }
            addNewMessage(message: Message(messageTextField.text!, username))
            
            messageTextField.text = ""
        }
        
        messageTextField.resignFirstResponder()
    }
    
    
    //MARK: - Handling the textField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Handling a keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        lowerBar.frame.origin.y = self.view.frame.height - keyboardHeight - lowerBar.frame.height
        messageBoard.frame.size.height = tableViewHeight - keyboardHeight - 10
        
        moveToBottom(animate: false)
    }
    
    func keyboardDidShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        lowerBar.frame.origin.y = self.view.frame.height - lowerBar.frame.height
        messageBoard.frame.size.height = tableViewHeight
    }
    
    func keyboardDidHide(_ notification: NSNotification) {
        moveToBottom(animate: true)
    }
    //MARK: - Private functions
    
    //adds new message to messageBoard
    func addNewMessage(message: Message) {
        messages += [message]
        saveMessages()
        addToMessageBoard(message)
    }
    
    func addToMessageBoard(_ message: Message) {
        messageBoard.beginUpdates()
        messageBoard.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .none)
        messageBoard.endUpdates()
    }
    
    func moveToBottom(animate: Bool) {
        if(messageBoard.contentSize.height > messageBoard.frame.height) {
            let bottomOfSet = CGPoint(x: 0, y: messageBoard.contentSize.height - messageBoard.frame.height)
            messageBoard.setContentOffset(bottomOfSet, animated: animate)
        }
    }
    
    func logOut() {
        self.performSegue(withIdentifier: "logOut", sender: nil)
    }
    
    func saveMessages() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(messages, toFile: Message.ArchiveURL.path)
        if (isSuccessfulSave) {
            print("Messages successfully saved")
        } else {
            print("Failed to save messages")
        }
    }
}

extension String {
    func subString(_ startIndex: Int, _ length: Int) -> String {
        if (self.count < length || startIndex+1 > self.count){
            return ""
        }
        var result = ""
        for i in startIndex...startIndex+length-1 {
            let index = self.index(self.startIndex, offsetBy: i)
            result += String(self[index])
        }
        return result
    }
    
    func at(_ index: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: index)
        return String(self[index])
    }
}

extension ChatRoomViewController: ServerConnectionDelegate {
    func receivedData(_ text: String) {
        if(text.subString(0, 3) == "MSG") {
            let msgUsernameLength = Int(text.subString(3, 2)) ?? 0
            let msgUsername = text.subString(5, msgUsernameLength)
            let messageLength = Int(text.subString(5+msgUsernameLength, 4)) ?? 0
            let message = text.subString(9+msgUsernameLength, messageLength)
            
            if(msgUsernameLength == 0 || messageLength == 0) {
                print("Wrong message format")
                return
            }
            addNewMessage(message: Message(message, msgUsername))
        }
        else if(text.subString(0, 3) == "DIS"){
            self.logOut()
        }
    }
}
