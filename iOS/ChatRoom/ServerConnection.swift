//
//  ServerConnection.swift
//  ChatRoom
//
//  Created by Lukasz Kawka on 15/09/2017.
//  Copyright © 2017 Lukasz Kawka. All rights reserved.
//

import UIKit

protocol ServerConnectionDelegate: class {
    func receivedData(_ text: String)
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
    func sendData(_ text: String) {
        let data = text.data(using: .utf8)!
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
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            print("The end of the stream has been reached")
            
            delegate?.receivedData("DIS")
        case Stream.Event.errorOccurred:
            print("An error has occurred on the stream")
            
            delegate?.receivedData("DIDNOTCONNECT")
        case Stream.Event.hasSpaceAvailable:
            print("The stream can accept bytes for writing")
        case Stream.Event.openCompleted:
            print("The open has completed successfully")
            
            delegate?.receivedData("DIDCONNECT")
        default:
            print("Unidetified event")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxTextLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxTextLength)
            
            //if some error has occured than bail
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            if let data = String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .utf8, freeWhenDone: true) {
                delegate?.receivedData(data)
            }
        }
        
    }
}
