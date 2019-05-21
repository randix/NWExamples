//
//  MTS.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//
// THIS IS A CLIENT ONLY IMPLEMENTATION

import Foundation
import Network


class MTSClient {
    
    var connected = false
    var hostname: String
    var port: UInt16
    var mtsReceiver: (_ receive: MTSMessage) -> Void
    
    var useTLS = false
    var clientCertificate: Data?
    
    var proxyHostname: String?
    var proxyPort: UInt16?
    var proxyUser: String?
    var proxyPassword: String?
    var proxyTransactComplete = false
    
    var connection: NWConnection?
    
    let await = DispatchSemaphore(value: 0)
    var waiting = false
    
    var buffer = Data()
    var expected = 0
    
    var Log: (_ log: String) -> Void
    
    init(log: @escaping (_ log: String) -> Void, url: String, mtsRcvr: @escaping (_ receive: MTSMessage) -> Void) {
        Log = log
        let s = url.components(separatedBy: ":")
        hostname = s[0]
        port = UInt16(s[1])!
        print(hostname, port)
        mtsReceiver = mtsRcvr
    }
    
    func WithTLS(certificate: Data?) -> MTSClient {
        useTLS = true
        clientCertificate = certificate
        return self
    }
    
    func WithProxy(ProxyURL: String, ProxyUser: String?, ProxyPassword: String?) -> MTSClient {
        let s = ProxyURL.components(separatedBy: ":")
        proxyHostname = s[0]
        proxyPort = UInt16(s[1])!
        proxyUser = ProxyUser
        proxyPassword = ProxyPassword
        return self
    }
    
    func Connect() -> MTSClient {
        Log("connect to \(hostname):\(port)")
        if useTLS {
            Log("using TLS")
            connection = NWConnection(host: NWEndpoint.Host(hostname), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tls)
        } else {
            Log("not using TLS")
            connection = NWConnection(host: NWEndpoint.Host(hostname), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tcp)
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
            Log("connected")
            self.connected = true
            break
        case .waiting(let error):
            // Handle connection waiting for network
            Log("waiting \(error)")
            break
        case .failed(let error):
            // Handle fatal connection error
            Log("failed \(error)")
            break
        case .preparing:
            // Handle fatal connection error
            Log("preparing")
            break
        default:
            Log("default \(newState)")
            break
        }
    }
    
    func setupReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, contentContext, isComplete, error) in
            if var data = data, !data.isEmpty {
                // … process the data …
                self.Log("did receive \(data.count) \(self.expected) bytes")
                if (self.buffer.count == 0 && self.expected == 0) {
                    self.expected  = Int(data.removeFirst())
                    self.expected |= Int(data.removeFirst()) << 8
                    self.expected |= Int(data.removeFirst()) << 16
                    self.expected |= Int(data.removeFirst()) << 24
                    self.Log("expected: \(self.expected) bytes")
                }
                self.buffer.append(data)
                self.Log("have \(self.buffer.count) expected \(self.expected)")
                if (self.buffer.count == self.expected) {
                    let jsonDecoder = JSONDecoder()
                    var mtsMessage: MTSMessage?
                    do {
                        mtsMessage = try jsonDecoder.decode(MTSMessage.self, from: self.buffer)
                    } catch {
                        print("receive json convert error")
                    }
                    if (self.waiting && mtsMessage!.Reply) {
                        self.waitReceiver(mtsMessage!)
                    } else {
                        self.mtsReceiver(mtsMessage!)
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
        Log("mtsMessage \(mtsMessage)")
        let jsonDecoder = JSONDecoder()
        print(mtsMessage.Route)
        switch MTSRequest(rawValue: mtsMessage.Route)! {
        case .Login:
            do {
                //obj = try jsonDecoder.decode(RMSLoginResponse.self, from: mtsMessage.Json.data(using: .utf8)!) as AnyObject
            } catch {
                print("RMSLoginResponse json convert error")
            }
            break
        case .OplCommands:
            do {
                //obj = try jsonDecoder.decode(OPLCommands.self, from: mtsMessage.Json.data(using: .utf8)!) as AnyObject
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
