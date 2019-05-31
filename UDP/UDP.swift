//
//  UDP.swift
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network


class UDPServer {
    
    init(_ log: @escaping (_  log: String) -> Void, port: UInt16, udpReceiver: @escaping(_ receive: Data) -> Void) {
        
    }
    
    func withTLS(certificate: Data, clientCertificateRequired: Bool) -> UDPServer {
        
        return self
    }
    
    func clientCertificateRequired(_ flag: Bool) -> Void {
        
    }
    
    func start() -> UDPServer {
        return self
    }
    
    func stop() -> Void {
        
    }
    
    func send(_ message: Data) {
        
    }
    
}

class UDPClient {
    
    var connection: NWConnection
    var connected: Bool = false
    
    var OplReceiver: (_ receive: String) -> Void
    
    var buffer: Data = Data()
    var expected: UInt32 = 0
    
    init(host: String, port: UInt16, oplReceiver: @escaping (_ receive: String) -> Void)
    {
        connection = NWConnection(host: "172.20.10.5", port: 10001, using: .udp)
        
        OplReceiver = oplReceiver
        
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
                    self.OplReceiver(s!)
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




//
//  OPL.swift
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network


class OPLClient {
    
    var oplListener: NWListener
    var oplConnection: NWConnection?
    
    var OplReceiver: (_ receive: Data) -> Void
    
    var Log: (_ msg: String) -> Void
    
    init(_ log: @escaping (_ log: String) -> Void, port: UInt16, oplReceiver: @escaping (_ receive: Data) -> Void) {
        
        Log = log
        OplReceiver = oplReceiver
        
        let p = NWParameters.udp
        oplConnection = NWConnection(host: NWEndpoint.Host("0.0.0.0"), port: NWEndpoint.Port(rawValue: port)!, using: p)
        
        p.allowLocalEndpointReuse = true
        oplListener = try! NWListener(using: p, on: NWEndpoint.Port(rawValue: port)!)
        
        //p.requiredLocalEndpoint = NWEndpoint.hostPort(host: "0.0.0.0", port: NWEndpoint.Port(rawValue: port)!)
        //oplListener = try! NWListener(using: p)
        
        oplListener.newConnectionHandler = { (newConnection) in
            print("incoming")
            
            newConnection.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print ("connection ready")
                    self.receive(from: newConnection)
                case .waiting(let error):
                    print ("connection waiting (\(error))")
                case .failed(let error):
                    print ("connection failed (\(error))")
                default:
                    print ("connection \(newState)")
                    break
                }
            }
            
            newConnection.start(queue: DispatchQueue(label: "receiverQueue"))
        }
        
        print("start listener...")
        oplListener.start(queue: DispatchQueue(label: "listenerQueue"))
    }
    
    func receive(from connection: NWConnection) {
        
        print(connection.endpoint.debugDescription)
        oplConnection = NWConnection(to: connection.endpoint, using: .udp)
        oplConnection!.start(queue: DispatchQueue(label: "connectionQueue"))
        
        connection.receiveMessage { (data, context, isComplete, error) in
            //report an error
            if let error = error {
                print(error)
                return
            }
            
            //process received data
            if let data = data, let message = String(data: data, encoding: .utf8)  {
                print("received message: \(message)")
                self.OplReceiver( data)
            }
            
            //restart receiving
            self.receive(from: connection)
        }
    }
    
    func send() {
        //let data = Data()
        //oplConnection!.send(content: data, completion: <#NWConnection.SendCompletion#>)
    }
}
