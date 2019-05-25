//
//  MTSHandler.swift
//  MTS
//
//  Created by Rand Dow on 5/20/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

struct MTSMessage: Codable {
    var Route: Int
    var JWT: String
    var Data: Data
    var Reply: Bool
    
    init(route: MTSRequest, jwt: String, data: Data, reply: Bool = false) {
        Route = route.rawValue
        JWT = jwt
        Data = data
        Reply = reply
    }
}

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
//    func MTSConvert<T:Codable>(_ data: Data) -> T? {
//        var obj: T
//        let jsonDecoder = JSONDecoder()
//        do {
//            obj = try jsonDecoder.decode(T.self, from: data)
//            return obj
//        } catch {
//            print("json convert error")
//        }
//        return nil
//    }
    
    static func MTSConvert(_ data: MTSMessage) throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
    
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
