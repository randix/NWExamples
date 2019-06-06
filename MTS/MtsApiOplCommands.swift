//
//  MtsApiOplCommands.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum OPLListType:Int {
    case Ping                = 1
    case RoutingTableRequest = 2
    case Enroll              = 3
    case ClearEnroll         = 4
}

struct MtsOPLCommands : Codable {
    var OPLLists: Dictionary<Int, [Data]>
}

func MTSConvert(_ data: MtsOPLCommands) throws -> Data {
    return try! JSONEncoder().encode(data)
}
