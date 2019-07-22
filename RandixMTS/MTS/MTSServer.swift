//
//  MTSServer.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation
import Network

/// Conforming types can act as an MTS server that an MTS client
/// can attempt to connect with using MTS transactions.
public protocol MTSServer: ICanCreateTLSParams {
    
    // MARK: - Properties
    
    /// This property stores a reference to an MTSDataModel with
    /// appropriate cached values needed to interact with MTS
    /// transport layer.
    var mtsModel: MTSDataModel { get set }
    
    /// This property is equal to the port id that network
    /// connections will use.
    var port: UInt16 { get }
    
    /// This property is a boolean value that is true when TLS
    /// certificate is required for connection.
    var clientCertRequired: Bool { get set }
    
    /// This is the network listener that will listen for
    /// connections.
    var listener: NWListener? { get set }

    // MARK: - Functions
    
    /// This method starts the server listening on its port.
    ///
    /// - returns: A discardableResult of self as MTSServer.
    func start() -> MTSServer
    
    /// This method disconnects specified client from server
    /// and performs any clean up required.
    ///
    /// - parameter client: The specific MTSClient to be
    ///                     disconnected.
    func mtsDisconnect(_ client: MTSClient)
}

extension MTSServer {
     
    /// This method uses passed arguments to configure connection
    /// for TLS using a certificate.
    ///
    /// - parameter certificate: The license to use for TLS config.
    /// - parameter clientCertificateRequired: When set to true,
    ///             this server instance will require TLS
    ///             certificate.
    /// - returns: A discardableResult of self: MTSServer
    @discardableResult
    mutating public func withTLS(certificate: Data?, clientCertificateRequired: Bool) -> MTSServer {
        mtsModel.isUsingTls = true
        mtsModel.certificate = certificate
        clientCertRequired = clientCertificateRequired
        
        return self
    }
    
    /// This method ends MTS transactions and closes connection.
    public func stop() -> Void {
        mtsModel.connection?.cancel()
    }
}
