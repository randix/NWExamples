//
//  MtsApi.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum MTSRequest: Int {
    case MtsOPL                  = 1  // <->
    
    case MtsLogin                = 2  //  ->
    case MtsLoginResponse        = 3  // <-
    
    case MtsCommunicationKeyReq  = 4  //  ->
    case MtsCommunicationKeys    = 5  // <-
    
    case MtsRoomsMap             = 7  // <->
    
    case MtsOplCommands          = 8  // <->
    
    case MtsFirmware             = 9  // <->
}

func mtsConvertWait(_ log: (_ log: String) -> Void, mtsMessage: MTSMessage) -> AnyObject {
    let decoder = JSONDecoder()
    var obj: AnyObject?
    let json = String(data: mtsMessage.data, encoding: .utf8)!
    print("json=\(json)")
    log("\(json)")
    switch MTSRequest(rawValue: mtsMessage.route)! {
    case .MtsCommunicationKeys:
        obj = try! decoder.decode(MtsCommunicationKeys.self, from: mtsMessage.data) as AnyObject
        break;
    case .MtsFirmware:
        obj = try! decoder.decode(MtsFirmware.self, from: mtsMessage.data) as AnyObject
        break
    case .MtsLoginResponse:
        obj = try! decoder.decode(MtsLoginResponse.self, from: mtsMessage.data) as AnyObject
        break
    case .MtsRoomsMap:
        obj = try! decoder.decode([MtsRoomToNodeIds].self, from: mtsMessage.data) as AnyObject
        break;
    case .MtsOplCommands:
        obj = try! decoder.decode(MtsOPLCommands.self, from: mtsMessage.data) as AnyObject
        break
    default:
        break
    }
    return obj!
}
