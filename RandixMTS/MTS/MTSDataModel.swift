//
//  MTSDataModel.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation
import Network

/// This value type contains the various IVars needed for MTS
/// clients and servers to make successful MTS transactions, and
/// their default values when necessary.
public struct MTSDataModel {
    
    // MARK: - Properties
    
    /// This public muteable variable stores an account name
    /// associated with USER for MTS authentication.
    public var user = "DefaultUser"
  
    /// This public muteable variable stores an account passphrase
    /// associated with USER for MTS authentication.
    public var pass = "DefaultPass"
    
    /// This public muteable variable stores a boolean value that
    /// is true when connecting with TLS certificates.
    public var isUsingTls = true
    
    /// This public muteable variable stores a raw data version of
    /// the certificate that is used with TLS connections.
    public var certificate: Data? 

    /// This public optional variable can store a string
    /// representation of JSON Web Token used for MTS
    /// authentication.
    public var jwt: String?
    
    /// This public muteable variable stores a boolean value that
    /// is true when client / server is connected.
    public var isConnected = false
    
    /// This optional property can store a reference to the
    /// network connection that MTS is interacting over.
    public var connection: NWConnection?
    
    /// This overrides convenience init in order to ensure that it
    /// is publicly accessible.
    public init() { }
}
