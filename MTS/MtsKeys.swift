//
//  MtsKeys.swift
//  MTS
//
//  Created by Rand Dow on 5/21/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import Foundation

enum KeyType: Int {
    case KOPLRMSEvent       = 1
    case KOPLNetwork        = 2
    
    case KOPLAccess         = 3
    case KOPLHostMessage    = 4
    case KSiteFactory       = 5
    case KSite              = 6
    case KSiteEncrypted     = 7
    case KMiFarePlusSite    = 8
    case KMiFarePlusKeyA    = 9
    case KMiFarePlusKeyB    = 10
    case KMiFareUltraLightC = 11
}

struct MtsCommunicationKeyReq : Codable {
    var AppKey: Data
}

struct RMSCommunicationKeys : Codable {
    var Keys: Dictionary<Int, [Data]>
}

struct PPCommunicationKeys : Codable {
    var Keys: Dictionary<Int, [Data]>
}
