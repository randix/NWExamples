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
    case Enroll               =  1
    case Login                =  2
    case LoginResponse        =  3
    case CommunicationKeyReq  =  4
    case PPCommunicationKeys  =  5
    case RMSCommunicationKeys =  6
    case RoomsMap             =  7
    case NodeIdsMap           =  8
    case OplCommands          =  9
    case OPL                  = 10
}
