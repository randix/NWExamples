//
//  ICanConvertFromMtsMessage.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation

/// Types conforming to this protocol have convert:from: method
/// signature.
public protocol ICanConvertFromMtsMessage {
    
    /// This method converts passed `MTSMessage` parameter into an
    /// concrete object conforming to `OnPortalRequestType`.
    ///
    /// - parameter mtsMessage: This parameter references an
    ///                         `MTSMessage` object that method
    ///                         will attempt to convert.
    /// - returns: A concrete object conforming to
    ///            `OnPortalRequestType`. If conversion fails, will
    ///            be an `OPError`.
    func convert(from mtsMessage: MTSMessage) -> MTSRequestType
}
