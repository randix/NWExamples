//
//  TypeAliases.swift
//  RandixMTS
//
//  Created by UTC Mobile Dev on 7/22/19.
//  Copyright © 2019 randix. All rights reserved.
//

import Foundation

// MARK: - Typealiases

/// This typealias defines: (_ log: String) -> Void
public typealias LoggerReference = (_ log: String) -> Void

// MARK: - Typealiases: MTS Library

/// This typealias defines: (_ client: OPClient) -> Void
///
/// - client: The MTSClient conformer that manages MTS transaction
///           passed as an argument.
public typealias MTSConnection = (_ client: MTSClient) -> Void

/// This typealias defines: (_ client: OPClient, _ receive:
/// MTSMessage) -> Void
///
/// - client: The MTSClient conformer that manages MTS transaction
///           passed as an argument.
/// - receive: The MTSMessage conformer that manages connection
///            passed as an argument.
public typealias MTSReceive = (_ client: MTSClient, _ receive: MTSMessage) -> Void

/// This typealias defines: (_ client: OPClient) -> Void
///
/// - client: The MTSClient conformer that manages MTS transaction
///           passed as an argument.
public typealias MTSDisconnect = (_ client: MTSClient) -> Void

/// This typealias defines: (_ mtsMessage: MTSMessage, _ log:
/// LoggerReference) -> MTSRequestType
///
/// - receive: The MTSMessage conformer that manages connection
///            passed as an argument.
public typealias MTSConvert = (_ mtsMessage: MTSMessage, _ log: LoggerReference) -> MTSRequestType
