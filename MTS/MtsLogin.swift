//
//  Login.swift
//  MTS
//
//  Created by Rand Dow on 5/1/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum AppId: Int {
    case RMSServer = 1
    case RMSRmNd
    case BTPP
}

struct MtsLogin : Codable {
    var Username: String
    var Password: String
    var AppId: Int
    var AppKey: Data
    
    init(user: String, password: String, appId: AppId, appKey: Data) {
        Username = user
        Password = password
        AppId = appId.rawValue
        AppKey = appKey
    }
}

struct RMSLoginResponse : Codable {
    var NodeAuth: String
    var ClientCertificate: Data?
    var ServerCertInfo: String
    var MtuBluetooh: Int
    var MtuOpl: Int
    var MtuMts: Int
}
