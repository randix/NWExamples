//
//  MtsApiRoomToNodeIds.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum NodeIdSubNetOffset : Int {
    case RoomNode  = 0
    case Repeater1 = 1
    case Repeater2 = 2
    case Lock1     = 3
    case Lock2     = 4
    case Lock3     = 5
    case Lock4     = 6
    case Lock5     = 7
}

// Request
struct MtsRoom : Codable {
    var RoomName: String
    
    init(_ room: String) {
        RoomName = room
    }
}

// Response
struct MtsRoomToNodeIds : Codable {
    var RoomName: String
    var NodeIds: [Int]
}

func MTSConvert(_ data: MtsRoom) throws -> Data {
    return try! JSONEncoder().encode(data)
}

func MTSConvert(_ data: [MtsRoomToNodeIds]) throws -> Data {
    return try! JSONEncoder().encode(data)
}


