//
//  MtsApiFirmware.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

struct MtsFirmwareReq : Codable {
    var Offset: Int
    var MaximumSegmentize: Int
}

struct MtsFirmware : Codable {
    var Offset: Int
    var SegmentSize: Int
    var IsFinal : Bool
    var Data: Data
}

func MTSConvert(_ data: MtsFirmwareReq) throws -> Data {
    return try! JSONEncoder().encode(data)
}

func MTSConvert(_ data: MtsFirmware) throws -> Data {
    return try! JSONEncoder().encode(data)
}
