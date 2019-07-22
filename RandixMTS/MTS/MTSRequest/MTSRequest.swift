//
//  MtsApi.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

/// Conforming types are messages that are able to request MTS
/// transactions over network connections.
public protocol MTSRequest: ICanLog, ICanConvertFromMtsMessage {
    
    // MARK: - Properties
    
    /// This read-only property is the only way to require enum
    /// conformance.
    var rawValue: Int { get }
}
