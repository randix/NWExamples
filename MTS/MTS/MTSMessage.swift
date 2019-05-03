//
//  MTSMessage.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

struct MTSMessage : Codable {
    var Route: String
    var Json: String
    
    init(route: String, json: String) {
        Route = route
        Json = json
    }
}
