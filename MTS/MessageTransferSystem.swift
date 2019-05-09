//
//  MTS.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network

struct MTSMessage : Codable {
    var Route: String
    var Json: String
    
    init(route: String, json: String) {
        Route = route
        Json = json
    }
}

class MTSServer {
    var ListenerPort: NWEndpoint.Port
    var Listener: NWListener?
    var ServerCertificate: Data?
    var ClientCertificateRequired: Bool = false
    var MtsReceiver: (_ receive: String) -> Void
    var clients: [MTSClient] = []
    
    init(port: UInt16, mtsReceiver: @escaping (_ receive: String) -> Void) {
        ListenerPort = NWEndpoint.Port(integerLiteral: port)
        MtsReceiver = mtsReceiver
    }
    
    func WithTLS(certificate: Data, clientCertificateRequired: Bool = false) -> MTSServer {
        ServerCertificate = certificate
        ClientCertificateRequired = clientCertificateRequired
        return self
    }
    
    func ClientCerficateRequired(clientCertificateRequired: Bool) -> Void {
        ClientCertificateRequired = clientCertificateRequired
    }
    
    func Start() throws -> MTSServer {
        //var parameters = NWParameters()
        Listener = try NWListener(using: .tcp, on: ListenerPort)
        Listener!.stateUpdateHandler = self.stateDidChange(to:)
        Listener!.newConnectionHandler = self.didAccept(connection:)
        Listener!.start(queue: .main)
        return self
    }
    
    func Stop() -> Void {
        // TODO
    }
    
    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .setup:
            break
        case .waiting:
            break
        case .ready:
            break
        case .cancelled:
            break
        case .failed(_):
            break
        @unknown default:
            break
        }
    }
    
    //    func listenerDidFail(error: error) {
    //
    //    }
    //
    func didAccept(connection: NWConnection) {
        
    }
}


class MTSClient {
    var Url: URL
    var Hostname: String?
    var Port: UInt16?
    var MtsReceiver: (_ receive: String) -> Void
    var useTLS: Bool = false
    var ClientCertificate: Data?
    var ProxyURL: URL?
    var ProxyUser: String?
    var ProxyPassword: String?
    
    var connection: NWConnection?
    var connected: Bool = false
    
    var buffer: Data = Data()
    var expected: UInt32 = 0
    
    init(url: URL, mtsReceiver: @escaping (_ receive: String) -> Void) {
        Url = url
        MtsReceiver = mtsReceiver
    }
    
    init(hostname: String, port: UInt16, mtsReceiver: @escaping (_ receive: String) -> Void) {
        Hostname = hostname
        Port = port
        Url = URL(string: "\(Hostname!):\(Port!)")!
        MtsReceiver = mtsReceiver
    }
    
    func WithTLS(certificate: Data?) -> MTSClient {
        useTLS = true
        ClientCertificate = certificate
        return self
    }
    
    func WithProxy(proxyURL: URL, proxyUser: String?, proxyPassword: String?) -> MTSClient {
        ProxyURL = proxyURL
        ProxyUser = proxyUser
        ProxyPassword = proxyPassword
        return self
    }
    
    func Connect() -> MTSClient {
        if useTLS {
            connection = NWConnection(host: "172.20.10.5", port: 10001, using: .tls)
        } else {
            connection = NWConnection(host: "172.20.10.5", port: 10001, using: .tcp)
        }
        connection!.stateUpdateHandler = self.stateDidChange(to:)
        setupReceive(on: connection!)
        connection!.start(queue: .main)
        return self
    }
    
    func stateDidChange(to newState: NWConnection.State) {
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
    
    func setupReceive(on connection: NWConnection) {
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
                self.setupReceive(on: connection)
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
        connection!.send(content: p+data, completion: .contentProcessed(({ (error) in
            if let error = error {
                print("error \(String(describing: error))")
                self.connectionFailed(error: error)
            }
            print("processed")
        })))
    }
    
    func sendEndOfStream() {
        connection!.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                self.connectionFailed(error: error)
            }
        }))
    }
    
}
