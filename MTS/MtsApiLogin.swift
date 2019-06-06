//
//  MtsApiLogin.swift
//  MTS
//
//  Created by Rand Dow on 6/5/19.
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

struct MtsLoginResponse : Codable {
    var NodeAuth: String
    var ClientCertificate: Data?
    var ServerCertInfo: String
    var MtuBluetooth: Int
    var MtuOpl: Int
    var MtuMts: Int
}

func MTSConvert(_ data: MtsLogin) throws -> Data {
    return try! JSONEncoder().encode(data)
}

func MTSConvert(_ data: MtsLoginResponse) throws -> Data {
    return try! JSONEncoder().encode(data)
}
