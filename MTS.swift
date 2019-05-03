//
//  MTS.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network

class MTSClient {
    
    var connection: NWConnection
    var connected: Bool = false
    
    var MtsReceiver: (_ receive: String) -> Void
    
    var buffer: Data = Data()
    var expected: UInt32 = 0
    
    init(useTLS: Bool, clientCert: [UInt8]?, host: String, port: UInt16,
         mtsReceiver: @escaping (_ receive: String) -> Void, proxy: String?, proxyUser: String?, proxyPassword: String?)
    {
        if useTLS {
            connection = NWConnection(host: "172.20.10.5", port: 10001, using: .tls)
        } else {
            connection = NWConnection(host: "172.20.10.5", port: 10001, using: .tcp)
        }
        MtsReceiver = mtsReceiver
        
        connection.stateUpdateHandler = { (newState) in
            switch(newState) {
            case .ready:
                // Handle connection established
                print("connected")
                self.connected = true
                break
            case .waiting(let error):
                // Handle connection waiting for network
                print("waiting \(error)")
                break
            case .failed(let error):
                // Handle fatal connection error
                print("failed \(error)")
                break
            case .preparing:
                // Handle fatal connection error
                print("preparing")
                break
            default:
                print("default \(newState)")
                break
            }
        }
        
        receiver(on: connection)
        connection.start(queue: .main)
    }

    
    func receiver(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, contentContext, isComplete, error) in
            if var data = data, !data.isEmpty {
                // … process the data …
                print("did receive \(data.count) \(self.expected) bytes")
                if (self.buffer.count == 0 && self.expected == 0) {
                    self.expected  = UInt32(data.removeFirst())
                    self.expected |= UInt32(data.removeFirst()) << 8
                    self.expected |= UInt32(data.removeFirst()) << 16
                    self.expected |= UInt32(data.removeFirst()) << 24
                    print("expected: \(self.expected) bytes")
                }
                self.buffer.append(data)
                print("have \(self.buffer.count) expected \(self.expected)")
                if (self.buffer.count == self.expected) {
                    let s = String(data: self.buffer, encoding: .utf8)
                    self.MtsReceiver(s!)
                    self.buffer = Data()
                    self.expected = 0
                }
            }
            if isComplete {
                // … handle end of stream …
                self.stop(status: "EOF")
            } else if let error = error {
                // … handle error …
                self.connectionFailed(error: error)
            } else {
                print("restart receiver")
                self.receiver(on: connection)
            }
        }
    }
    
    func stop(status: String) {
        print("status \(status)")
    }
    
    func connectionFailed(error: NWError?) {
        print("error \(String(describing: error))")
    }
    
    
    
    func send(_ data: Data) {
        print("send")
        let len = data.count;
        var p: Data = Data()
        p.append(UInt8( len        & 0xff))
        p.append(UInt8((len >> 8)  & 0xff))
        p.append(UInt8((len >> 16) & 0xff))
        p.append(UInt8( len >> 24))
        connection.send(content: p+data, completion: .contentProcessed(({ (error) in
            if let error = error {
                print("error \(String(describing: error))")
                self.connectionFailed(error: error)
            }
            print("processed")
        })))
    }
    
    func sendEndOfStream() {
        connection.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                self.connectionFailed(error: error)
            }
        }))
    }
    
}
