//
//  MTSMessage.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation

/// This value type defines the MTS primary message structure.
public struct MTSMessage: Codable {
    
    /// This public property stores message route as an integer.
    public var route: Int

    /// This public property stores JSON Web Token as a string.
    public var jwt: String

    /// This public property stores messages content as data.
    public var data: Data

    /// This public property stores awknowledgement requirement.
    public var reply: Bool

    /// This optional public property stores attribute route.
    public var attributeRoute: String?
    
    /// - parameter request: MTSRequest type for MTS transaction.
    /// - parameter attributeRoute: Optional attribute route path.
    public init(request: MTSRequest, attributeRoute: String?,
         jwt: String, data: Data, reply: Bool = false) {
        self.route = request.rawValue
        self.jwt = jwt
        self.data = data
        self.reply = reply
    }
}
