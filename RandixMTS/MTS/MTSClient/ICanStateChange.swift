//
//  ICanStateChange.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation
import Network

/// Conforming types where Self: MTSClient, inherit the
/// `stateDidChange:to` convenience method.
public protocol ICanStateChange: AnyObject, ICanLog, MTSClientDelegate { }

extension ICanStateChange where Self: MTSClient {
    
    /// This convenience method logs state changes and updates
    /// self when connection is ready, firing off `mtsConnect`
    /// and updating `mtsModel.isConnected` boolean value.
    ///
    /// - parameter newState: The NWConnection.State that
    ///                       connection has changed to.
    func stateDidChange(to newState: NWConnection.State) {
        switch (newState) {
            
        // Handle connection established
        case .ready:
            log("connected")
            mtsModel.isConnected = true
            mtsConnect()
            
        // Handle connection waiting for network
        case .waiting(let error): log("waiting3 \(error)")
            
        // Handle fatal connection error
        case .failed(let error): log("failed \(error)")
            
        // Handle fatal connection error
        case .preparing: log("preparing")
            
        default: log("default \(newState)")
        }
    }
}
