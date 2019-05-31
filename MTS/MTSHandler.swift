//
//  MTSHandler.swift
//  MTS
//
//  Created by Rand Dow on 5/20/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum MTSRequest: Int {
    case OPL                  = 1  // <->
    case Login                = 2  //  ->
    case LoginResponse        = 3  // <-
    case CommunicationKeyReq  = 4  //  ->
    case PPCommunicationKeys  = 5  // <-
    case RMSCommunicationKeys = 6  // <-
    case RoomsMap             = 7  // <->
    case OplCommands          = 8  // <->
}

class MTSHandler {
    
    static func MTSConvert(_ data: MtsLogin) throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
    
    static func MTSConvert(_ data: Room) throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
    
    static func MTSConvert(_ data: MtsCommunicationKeyReq) throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
    
    static func MTSConvert(_ data: OPLCommands) throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
}
