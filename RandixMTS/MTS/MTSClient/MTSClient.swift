//
//  IMTSClient.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation
import Network

/// Conforming types can conduct MTS transactions over network
/// connections.
public protocol MTSClient: ICanCreateTLSParams, ICanStateChange {
    
    // MARK: - Properties
    
    /// This property stores a reference to an MTSDataModel with
    /// appropriate cached values needed to interact with MTS
    /// transport layer.
    var mtsModel: MTSDataModel { get set }
    
    /// This property stores a reference to an MTSClientDelegate
    /// which provides protocol specific behaviors for MTS
    /// transport layer.
    var delegate: MTSClientDelegate? { get set }
    
    /// This property stores the value of an UInt16 value that
    /// equals port number to be used by MTS transport layer.
    var port: UInt16 { get }
    
    /// This property stores the value of an string value that
    /// equals host address to be used by MTS transport layer.
    var host: String { get }
    
    /// This optional property can store the object requested
    /// during MTS transaction. If nil, no object was recovered.
    var requestedObj: MTSRequestType? { get set }
    
    /// This private constant stores a dispatch semaphore in order
    /// to block thread during asynchronous waits.
    var await: DispatchSemaphore { get }
    
    /// This private boolean is true when thread is blocked and
    /// client awaits connection.
    var isWaiting: Bool { get set }
    
    /// This ivar stores expected message length for recursive
    /// transactions.
    var expected: Int { get set }    

    /// This ivar temporarily caches data that has been downloaded
    /// over MTS for cross method use and recurssion.
    var buffer: Data { get set }
    
    /// This boolean property allows for any process to register
    /// connection no longer needed. Between transactions, it will
    /// be checked to ensure that connection is terminated when data
    /// transactions are complete.
    var isNeedsConnectionKilled: Bool { get set }
    
    // MARK: - Functions
    
    /// After `sendWait` is called, if it is successful this method
    /// will be called to handle conversion of requested object
    /// into a predefined MTSRequestType.
    ///
    /// - Note: Await ivar should be signalled here, and isWaiting
    ///         should be set to false.
    ///
    /// - parameter mtsMessage: The MTSMessage that was used to
    ///                         initiate the original transaction
    ///                         request.
    func waitReceiver(_ mtsMessage: MTSMessage)
}

extension MTSClient {
    
    /// This method uses passed arguments to configure connection
    /// for TLS using a certificate.
    ///
    /// - parameter certificate: The license to use for TLS config.
    /// - returns: A discardableResult of self: MTSClient.
    @discardableResult
    public func withTLS(_ certificate: Data? = nil) -> MTSClient {
        mtsModel.isUsingTls = true
        mtsModel.certificate = certificate
        return self
    }
    
    /// This method attempts to connect to MTS server.
    ///
    /// - returns: A discardableResult of self as MTSClient.
    @discardableResult
    public func connect() -> MTSClient {
        log("connect to \(host):\(port) (TLS=\(mtsModel.isUsingTls))")
        // TODO: client cert not implemented
        if mtsModel.connection != nil {
            // this was called from the server upon connection
            
        } else {
            // TODO: proxy not implemented
            let myHost = NWEndpoint.Host(host)
            let myPort = NWEndpoint.Port(rawValue: UInt16(port))!
            
            // TODO: !! #TLS This conditional needs to be breaklined when we test for TLS issues with iOS Server App, as iOS requires TLS (with added conditions, i.e. over 2k in size, non-zero, etc...).
            if mtsModel.isUsingTls {
                mtsModel.connection = NWConnection(host: myHost,
                                                   port: myPort,
                                                   using: createTLSParameters(allowInsecure: true, queue: .main))
            } else {
                mtsModel.connection = NWConnection(host: myHost,
                                                   port: myPort,
                                                   using: .tcp)
            }
        }
        mtsModel.connection!.stateUpdateHandler = stateDidChange
        
        if let connection = mtsModel.connection {
            setupReceive(on: connection)
        }
        
        mtsModel.connection?.start(queue: .main)
        
        return self
    }
   
    /// This method is where failed connections are handled.
    ///
    /// - parameter error: The NWError generated during connection
    ///                    failure.
    public func connectionFailed(error: NWError?) {
        log("error \(String(describing: error))")
    }
    

    /// This method ends MTS transactions and closes connection.
    ///
    /// - parameter status: The status before stop was triggered.
    public func stop(_ status: String) {
        log("stopping \(status)")
        sendEndOfStream()
    }
    
    /// This method closes connection hosting MTS transactions.
    private func sendEndOfStream() {
        mtsModel.connection!.send(content: nil,
                                  contentContext: .defaultStream,
                                  isComplete: true,
                                  completion: .contentProcessed({ error in
            if let error = error {
                self.connectionFailed(error: error)
            }
        }))
    }
    
    /// This method sends passed argument of MTS connection.
    ///
    /// - parameter data: This argument is a raw Data type.
    public func send(_ data: Data) {
        log("MTSClient.send:data \(data)")
        let len = data.count;
        var p: Data = Data()
        p.append(UInt8( len        & 0xff))
        p.append(UInt8((len >> 8)  & 0xff))
        p.append(UInt8((len >> 16) & 0xff))
        p.append(UInt8( len >> 24))
        mtsModel.connection!.send(content: p+data, completion: .contentProcessed(({ (error) in
            if let error = error {
                self.log("MTSClient.send.error \(String(describing: error))")
                self.connectionFailed(error: error)
            }
            self.log("MTSClient.send processed")
        })))
        log("MTSClient.send finished")
    }    
    
    /// This method sends passed argument of MTS connection.
    ///
    /// - parameter msg: A predefined MTSMessage.
    public func send(_ msg: MTSMessage) {
        log("MTSClient.send:msg \(msg)")
        
        if let data = try? JSONEncoder().encode(msg) {
            send(data)
        } else {
            log("MTSClient.send FAIL")
        }
    }
    
    /// This method is where conforming type will handle received
    /// objects from the connection hosting MTS transactions.
    ///
    /// - parameter connection: The network connection hosting MTS
    ///                         transactions.
    public func setupReceive(on connection: NWConnection) {
        
        connection.receive(minimumIncompleteLength: 1,
                           maximumLength: 65536)
        { data, contentContext, isComplete, error in
            if var data = data, !data.isEmpty {
                // … process the data …
                self.log("did receive \(data.count) \(self.expected) bytes")
                if (self.buffer.count == 0 && self.expected == 0) {
                    self.expected  = Int(data.removeFirst())
                    self.expected |= Int(data.removeFirst()) << 8
                    self.expected |= Int(data.removeFirst()) << 16
                    self.expected |= Int(data.removeFirst()) << 24
                    self.log("expected: \(self.expected) bytes")
                }
                self.buffer.append(data)
                self.log("have \(self.buffer.count) expected \(self.expected)")
                if (self.buffer.count == self.expected) {
                    let mtsMessage = try! JSONDecoder().decode(MTSMessage.self, from: self.buffer)
                    self.log("waiting1: \(self.isWaiting)")
                    if (self.isWaiting && mtsMessage.reply) {
                        self.waitReceiver(mtsMessage)
                    } else {
                        self.mtsReceive(mtsMessage)
                    }
                    self.buffer = Data()
                    self.expected = 0
                }
            }
            
            if isComplete || self.isNeedsConnectionKilled {
                // … handle end of stream …
                self.stop("EOF")
                
                // todo -- tell server if we are on server
                // todo -- tell application
            } else if let error = error {
                // … handle error …
                self.log("error")
                self.connectionFailed(error: error)
                
                // todo -- tell server if we are on server
                // todo -- tell application
            
            } else {
                self.log("restart receiver")
                self.setupReceive(on: connection)
            }
        }
    }
    
    
    /// This method is where conforming type will coordinate sending
    /// over MTS transaction and then waiting for a response to sent
    /// request.
    ///
    /// - parameter data: A predefined MTSMessage that requests an
    ///                   acknowledgement or query results.
    /// - returns: The MTSRequestType returned from MTS transaction.
    public func sendWait(_ data: MTSMessage) -> MTSRequestType {
        log("sendwait")
        isWaiting = true
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            self.send(data);
            self.await.wait()
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
        
        return requestedObj!
    }
}
