//
//  Message.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 12/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

class Message: NSObject, NSCoding {
    //MARK: - Propeties
    
    var text = ""
    var id = ""
    
    //MARK: - Initialization
    
    init(_ text: String, _ id: String){
        self.text = text
        self.id = id
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("messages")
    
    //MARK: - Types
    
    struct PropertyKey {
        static let text = "text"
        static let id = "id"
    }
    
    //MARK: - NSEncoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: PropertyKey.text)
        aCoder.encode(id, forKey: PropertyKey.id)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObject(forKey: PropertyKey.text) as! String
        let id = aDecoder.decodeObject(forKey: PropertyKey.id) as! String
        
        self.init(String(describing: text), String(describing: id))
    }
}
