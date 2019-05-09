//
//  MTS.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation
import Network

enum MTSType: Int{
    case Request = 1
    case Reply   = 2
}
struct MTSMessage : Codable {
    var Route: Int
    var MessageType: Int
    var Json: String
    
    init(route: MTSRequest, messageType: MTSType, json: String) {
        Route = route.rawValue
        MessageType = messageType.rawValue
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
    var MtsReceiver: (_ receive: MTSMessage) -> Void
    
    var useTLS = false
    var ClientCertificate: Data?
    
    var ProxyURL: URL?
    var ProxyUser: String?
    var ProxyPassword: String?
    
    var connection: NWConnection?
    var connected = false
    
    let await = DispatchSemaphore(value: 0)
    var waiting = false
    
    var buffer = Data()
    var expected = 0
    
    init(url: URL, mtsReceiver: @escaping (_ receive: MTSMessage) -> Void) {
        Url = url
        MtsReceiver = mtsReceiver
    }
    
    init(hostname: String, port: UInt16, mtsReceiver: @escaping (_ receive: MTSMessage) -> Void) {
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
                    self.expected  = Int(data.removeFirst())
                    self.expected |= Int(data.removeFirst()) << 8
                    self.expected |= Int(data.removeFirst()) << 16
                    self.expected |= Int(data.removeFirst()) << 24
                    print("expected: \(self.expected) bytes")
                }
                self.buffer.append(data)
                print("have \(self.buffer.count) expected \(self.expected)")
                if (self.buffer.count == self.expected) {
                    let jsonDecoder = JSONDecoder()
                    var mtsMessage: MTSMessage?
                    do {
                        mtsMessage = try jsonDecoder.decode(MTSMessage.self, from: self.buffer)
                    } catch {
                        print("receive json convert error")
                    }
                    if (self.waiting && MTSType(rawValue: mtsMessage!.MessageType) == .Reply) {
                        self.waitReceiver(mtsMessage!)
                    } else {
                        self.MtsReceiver(mtsMessage!)
                    }
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
    
    var obj: AnyObject?
    func sendAwait(_ data: Data) -> AnyObject {
        waiting = true
        send(data);
        await.wait()
        return obj!
    }
    func waitReceiver(_ mtsMessage: MTSMessage) {
        print("mtsMessage \(mtsMessage)")
        let jsonDecoder = JSONDecoder()
        print(mtsMessage.Route)
        switch MTSRequest(rawValue: mtsMessage.Route)! {
        case .Login:
            do {
                obj = try jsonDecoder.decode(RMSLoginResponse.self, from: mtsMessage.Json.data(using: .utf8)!) as AnyObject
            } catch {
                print("RMSLoginResponse json convert error")
            }
            break
        case .OplCommands:
            do {
                obj = try jsonDecoder.decode(OPLCommands.self, from: mtsMessage.Json.data(using: .utf8)!) as AnyObject
            } catch {
                print("OPLCommands json convert error")
            }
            break
        default:
            break
        }
        waiting = false
        await.signal()
    }
    
    func sendEndOfStream() {
        connection!.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                self.connectionFailed(error: error)
            }
        }))
    }
    
}
