//
//  RoomConfig.swift
//  MTS
//
//  Created by Rand Dow on 5/8/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum OPLListType:Int {
    case Ping                = 1
    case RoutintTableRequest = 2
    case Enroll              = 3
    case ClearEnroll         = 4
}
struct OPLCommands : Codable {
    var OPLLists: Dictionary<Int, [Data]>
}
