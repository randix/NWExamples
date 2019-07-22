//
//  MTSClientDelegate.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation

/// Conformers to this protocol can serve as a delegate for
/// MTSClient conformers.
public protocol MTSClientDelegate {
    
    /// This method is where delegate defines connection behavior.
    func mtsConnect()
    
    /// This method is where delegate defines disconnection
    /// behavior.
    func mtsDisconnect()
    
    /// This method is where delegate defines how received MTS
    /// messages are handled.
    ///
    /// - parameter mtsMessage: This parameter references MTS
    ///                         message received.
    func mtsReceive(_ mtsMessage: MTSMessage)
}
