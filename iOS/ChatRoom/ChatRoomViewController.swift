//
//  ChatRoomViewController.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 08/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit



class ChatRoomViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
    //green, blue, purple, grey, red. teal, pink, idigo
    var colors = [UIColor(red:0.30, green:0.69, blue:0.31, alpha:0.9), UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0), UIColor(red:0.61, green:0.15, blue:0.69, alpha:0.9), UIColor(red:0.38, green:0.49, blue:0.55, alpha:0.9), UIColor(red:0.90, green:0.22, blue:0.21, alpha:0.9), UIColor(red:0.00, green:0.54, blue:0.48, alpha:0.9), UIColor(red:0.91, green:0.12, blue:0.39, alpha:0.9), UIColor(red:0.25, green:0.32, blue:0.71, alpha:0.9)]
    
    var assignedColor: [String: UIColor] = [:]
    
    var serverConnection = ServerConnection()
    
    var messageBoard: UIStackView!
    var username: String?
    
    var alert: UIAlertController!
    
    var textWidth: CGFloat!
    var keyboardHeight: CGFloat!
    var scrollViewHeight: CGFloat!
    var scrollViewWidth: CGFloat!
    var scrollViewMargin: CGFloat = 4
    
    var messages = [Message]()
    
    var orangeColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    var grayColor = UIColor(red:0.58, green:0.60, blue:0.60, alpha:1.0)
    var messageColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:0.85)

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet weak var lowerBar: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load messages from memeory
        if let array = NSKeyedUnarchiver.unarchiveObject(withFile: Message.ArchiveURL.path) as? [Message] {
            messages += array
        }
        
        //setting up observers for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide , object: nil)

        //Setting main label
        usernameLabel.text = username ?? ""
        
        //some lowerBar setting up
        lowerBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.setTitleColor(orangeColor, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped(button:)), for: .touchUpInside)
        messageTextField.delegate = self
        
        //Setting up scrollview and stackView
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: scrollViewMargin).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: scrollViewMargin).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: lowerBar.topAnchor).isActive = true
        
        messageBoard = UIStackView()
        scrollView.addSubview(messageBoard)
        messageBoard.translatesAutoresizingMaskIntoConstraints = false
        
        messageBoard.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        messageBoard.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        messageBoard.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        messageBoard.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        
        messageBoard.axis  = UILayoutConstraintAxis.vertical
        messageBoard.distribution  = UIStackViewDistribution.equalSpacing
        messageBoard.alignment = UIStackViewAlignment.top
        messageBoard.spacing = 20.0
        
        //getting sizes
        scrollViewHeight = scrollView.frame.height
        scrollViewWidth = self.view.frame.width - 2 * scrollViewMargin
        textWidth = CGFloat(scrollViewWidth * 0.8)
        
        loadMessages()
        moveToBottom(animate: false)
        
        logOutButton.setTitleColor(orangeColor, for: .normal)
        refreshButton.setTitleColor(orangeColor, for: .normal)
        
        alert = UIAlertController(title: "Menu", message: "*Additional features*", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //only for now
        let host = "localhost"
        let port: UInt32 = 9997
        
        serverConnection.delegate = self
        //serverConnection.setUpNetworkConnection(host: host, port: port)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //serverConnection.stop()
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
    //MARK: - Button handling
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        //deleting all messages
        /*messages.removeAll()
        saveMessages()
        
        loadMessages()*/
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Handling the textField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped(button: sendButton)
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Handling a keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        lowerBar.frame.origin.y = self.view.frame.height - keyboardHeight - lowerBar.frame.height
        scrollView.frame.size.height = scrollViewHeight - keyboardHeight - 10
        moveToBottom(animate: false)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        lowerBar.frame.origin.y = self.view.frame.height - lowerBar.frame.height
        scrollView.frame.size.height = scrollViewHeight
    }
    
    func keyboardDidHide(_ notification: NSNotification) {
        moveToBottom(animate: true)
    }
    //MARK: - Private functions
    
    func sendButtonTapped(button: UIButton) {
        if(messageTextField.text! != "") {
            let newMessage = Message(messageTextField.text!, username!)
            messages += [newMessage]
            saveMessages()
            addNewMessage(newMessage)
            
            messageTextField.text = ""
        }
        
        messageTextField.resignFirstResponder()
    }
    
    func loadMessages() {

        //clear data
        for v in messageBoard.subviews {
            messageBoard.removeArrangedSubview(v)
        }
        
        //load messages
        for message in messages {
            addNewMessage(message)
        }
    }
    
    //adds new message to messageBoard (stackView)
    func addNewMessage(_ message: Message) {
        //'v' view allows the label to be on the right side
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        //label.layer.backgroundColor = messageColor.cgColor
        //label.layer.cornerRadius = 7.0
        label.text = message.text
        label.textColor = UIColor.white
        
        let size = label.sizeThatFits(CGSize(width: self.textWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if(label.intrinsicContentSize.width > textWidth!) {
            label.widthAnchor.constraint(equalToConstant: textWidth).isActive = true
        }
        
        v.widthAnchor.constraint(equalToConstant: scrollViewWidth).isActive = true
        v.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        v.addSubview(label)
        
        label.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        
        if(message.id == username){
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
            label.textAlignment = NSTextAlignment.right
            label.layer.backgroundColor = messageColor.cgColor
        } else {
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
            
            if(assignedColor[message.id] == nil) {
                assignedColor[message.id] = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            }
            label.layer.backgroundColor = assignedColor[message.id]?.cgColor
        }
        
        messageBoard.addArrangedSubview(v)
    }
    
    func moveToBottom(animate: Bool) {
        if(scrollView.contentSize.height > scrollView.frame.height) {
            let bottomOfSet = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height)
            scrollView.setContentOffset(bottomOfSet, animated: animate)
        }
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

extension ChatRoomViewController: ServerConnectionDelegate {
    func receivedString(_ text: String) {
        //do something here with unprocessd text
    }
}
