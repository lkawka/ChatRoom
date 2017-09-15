//
//  ServerConnection.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 15/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

protocol ServerConnectionDelegate: class {
    func receivedString(_ text: String)
}

class ServerConnection: NSObject {
    weak var delegate: ServerConnectionDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    let maxTextLength = 4096 //Probably for later change
    
    func setUpNetworkConnection(host: String, port: UInt32) {
        //initializing two socket streams
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        //binding streams and connecting them to the host
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host as CFString, port, &readStream, &writeStream)
        
        //retaining references
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        //adding streams to the run loop
        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)
        
        inputStream.delegate = self
        
        inputStream.open()
        outputStream.open()
        
    }
    
    //function that sends already processed string
    func sendString(string: String) {
        let data = string.data(using: .ascii)!
        _ = data.withUnsafeBytes {
            outputStream.write($0, maxLength: data.count)
        }
    }
    
    func stop() {
        inputStream.close()
        outputStream.close()
    }
}

extension ServerConnection: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("Message received")
        case Stream.Event.endEncountered:
            print("Message received 2")
        case Stream.Event.errorOccurred:
            print("Error occured")
        case Stream.Event.hasSpaceAvailable:
            print("Has space available")
        default:
            print("Some other event..")
        }
    }
    
    func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxTextLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxTextLength)
            
            //if some error has occured than bail
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            if let string = String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .ascii, freeWhenDone: true) {
                delegate?.receivedString(string)
            }
        }
        
    }
}
