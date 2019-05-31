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
    
    
//    switch MTSRequest(rawValue: mtsMessage.Route)! {
//    
//    case .LoginResponse:
//    obj = try! decoder.decode(MtsLoginResponse.self, from: mtsMessage.Data) as AnyObject
//    break
//    
//    case .PPCommunicationKeys:
//    obj = try! decoder.decode(PPCommunicationKeys.self, from: mtsMessage.Data) as AnyObject
//    break;
//    
//    case .RoomsMap:
//    obj = try! decoder.decode(RoomToNodeIds.self, from: mtsMessage.Data) as AnyObject
//    break;
//    
//    case .OplCommands:
//    obj = try! decoder.decode(OPLCommands.self, from: mtsMessage.Data) as AnyObject
//    break
//    
//    default:
//    break
//    }
}
