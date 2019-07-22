//
//  ICanLog.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation

/// Conforming types are required to specify a logging function.
public protocol ICanLog {
    
    /// This method provides callbacks to logging activity,
    /// which can be executed in an environmentally compatible
    /// way.
    ///
    /// - parameter msg: This parameter references a text string
    ///                  describing the logging message.
    func log(_ msg: String)
}

/// Conforming types are required to specify a reference to a
/// logging function.
public protocol IHasLog {
    
    /// This read-only property stores a reference to a logging
    /// method that conforms to `LoggerReference` signature.
    var log: LoggerReference { get }
}
