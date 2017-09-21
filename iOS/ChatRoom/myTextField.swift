//
//  MyTextField.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 07/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

class MyTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var themeColor = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    var borderColor = UIColor(red:0.58, green:0.60, blue:0.60, alpha:1.0)
    
    var height = 35
    var margin = 5
    
    var placeholderText: String = "" {
        didSet {
            
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 1.0
            self.layer.cornerRadius = 16.0
            
            let placeholderObject = NSMutableAttributedString(string: self.placeholderText)
            placeholderObject.addAttribute(NSForegroundColorAttributeName, value: themeColor, range: NSRange(location:0, length: self.placeholderText.characters.count))
            placeholderObject.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica", size: 15.0)!, range:NSRange(location:0, length: self.placeholderText.characters.count))
            
            self.attributedPlaceholder = placeholderObject
            
            selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.endOfDocument)
            
            if (self.placeholderText == "Password" || self.placeholderText == "Repeat Password") {
                self.isSecureTextEntry = true
            }
            
            // Constaints
            
            let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(height))
            
            NSLayoutConstraint.activate([heightConstraint])
        }
    }
    

}
