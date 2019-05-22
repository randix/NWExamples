//
//  RoomConfig.swift
//  MTS
//
//  Created by Rand Dow on 5/8/19.
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

struct RoomId : Codable {
    var RoomId: String
}

struct RoomToNodeIds : Codable {
    var RoomName: String
    var NodeIds: [Int]
}

struct RoomToNodeIdsMap : Codable {
    var RoomToNodeIds: [RoomToNodeIds]
}

struct NodeIdToRoom : Codable {
    var NodeId: Int
    var RoomName: String
}

struct NodeIdsToRoomsMap : Codable {
    var NodeIdToRoom: [NodeIdToRoom]
}

enum OPLListType:Int {
    case Ping                = 1
    case RoutintTableRequest = 2
    case Enroll              = 3
    case ClearEnroll         = 4
}
struct OPLCommands : Codable {
    var OPLLists: Dictionary<Int, [Data]>
}
