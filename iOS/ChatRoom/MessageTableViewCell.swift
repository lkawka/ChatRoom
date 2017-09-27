//
//  MessageTableViewCell.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 25/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    var label = UILabel()
    var margin: CGFloat = 4

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(message: String, width: CGFloat, shiftRight: Bool, color: UIColor, viewWidth: CGFloat) {
        label.text = message
        label.numberOfLines = 0
        label.backgroundColor = color
        label.textColor = UIColor.white
        
        var orginX: CGFloat = 0

        let labelSize = label.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        
        if(shiftRight) {
            orginX = viewWidth - label.intrinsicContentSize.width
        }
        
        label.frame = CGRect(origin: CGPoint(x: orginX, y:margin), size: labelSize)
    }

}
