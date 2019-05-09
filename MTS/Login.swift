//
//  Login.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

struct Login : Codable {
    var User: String
    var Password: String
    
    init(user: String, password: String) {
        User = user
        Password = password
    }
}

struct RMSLoginResponse : Codable {
    var ClientCertificate: Data?
}
