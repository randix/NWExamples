//
//  UDP.swift
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network


class UDPServer {
    
    private let log: (_ log: String) -> Void
    private let listener: NWListener
    private let port: UInt16
    private let udpReceiver: (_ receive: Data) -> Void
    
    private var clientCertificate: Data?
    private var clientCertRequired = false
    
    private var connection: NWConnection?
    
    init(_ log: @escaping (_  log: String) -> Void, port: UInt16, udpReceiver: @escaping(_ receive: Data) -> Void) {
        self.log = log
        self.port = port
        self.udpReceiver = udpReceiver

        let p = NWParameters.udp
        p.allowLocalEndpointReuse = true
        listener = try! NWListener(using: p, on: NWEndpoint.Port(rawValue: port)!)
    }
    
    func withTLS(certificate: Data, clientCertificateRequired: Bool = false) -> UDPServer {
        clientCertificate = certificate
        clientCertRequired = clientCertificateRequired
        return self
    }
    
    func clientCertificateRequired(_ clientCertificateRequired: Bool) -> Void {
        clientCertRequired = clientCertificateRequired
    }
    
    func start() -> UDPServer {
        listener.newConnectionHandler = { (newConnection) in
            self.log("incoming")
            newConnection.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    self.log("connection ready")
                    self.receive(newConnection)
                case .waiting(let error):
                    self.log("connection waiting (\(error))")
                case .failed(let error):
                    self.log("connection failed (\(error))")
                default:
                    self.log("connection \(newState)")
                    break
                }
            }
            newConnection.start(queue: DispatchQueue(label: "receiverQueue"))
        }
        log("start listener...")
        listener.start(queue: DispatchQueue(label: "listenerQueue"))
        return self
    }
    
    func stop() -> Void {
        
    }
    
    private func receive(_ connection: NWConnection) {
        self.connection = connection
        log(connection.endpoint.debugDescription)
//        oplConnection = NWConnection(to: connection.endpoint, using: .udp)
//        oplConnection!.start(queue: DispatchQueue(label: "connectionQueue"))
        connection.receiveMessage { (data, context, isComplete, error) in
            //report an error
            if let error = error {
                self.log("\(error)")
                return
            }
            //process received data
            if let data = data, let message = String(data: data, encoding: .utf8)  {
                self.log("received message: \(message)")
                self.udpReceiver(data)
            }
            //restart receiving
            self.receive(connection)
        }
    }
    
    func send(_ message: Data) {
        //connection.send(
    }
}

class UDPClient {
    
    private let log: (_  log: String) -> Void
    private let host: String
    private let port: UInt16
    private let udpReceiver: (_ receive: String) -> Void
    
    private let connection: NWConnection
    var connected: Bool = false
    private var buffer: Data = Data()
    private var expected: UInt32 = 0
    
    init(_ log: @escaping (_  log: String) -> Void, host: String, port: UInt16, udpReceiver: @escaping (_ receive: String) -> Void)
    {
        self.log = log
        self.host = host
        self.port = port
        self.udpReceiver = udpReceiver
        
        connection = NWConnection(host: "172.20.10.5", port: 10001, using: .udp)

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
    
    func withTLS() {
        
    }
    
    private func receiver(on connection: NWConnection) {
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
                    self.udpReceiver(s!)
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
    
    private func connectionFailed(error: NWError?) {
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
