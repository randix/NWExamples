//
//  ICanCreateTLSParams.swift
//  OnityComms
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import Foundation
import Network

/// Conforming types get `createTLSParameters:allowInsecure:queue`
/// convenience method.
public protocol ICanCreateTLSParams { }

extension ICanCreateTLSParams {
     
    /// This convenience method generates TLS parameters for
    /// specified arguments.
    ///
    /// - parameter allowInsecure: If true, insecure TLS
    ///                            connections authorized.
    /// - parameter queue: This is the dispacth queue that will
    ///                    host TLS authentication.
    /// - returns: Networking Parameters from TLS connection.
    public func createTLSParameters(allowInsecure: Bool, queue: DispatchQueue) -> NWParameters {
        let options = NWProtocolTLS.Options()
        sec_protocol_options_set_verify_block(options.securityProtocolOptions, { (sec_protocol_metadata, sec_trust, sec_protocol_verify_complete) in
            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            var error: CFError?
            if SecTrustEvaluateWithError(trust, &error) {
                sec_protocol_verify_complete(true)
            } else {
                if allowInsecure == true {
                    sec_protocol_verify_complete(true)
                } else {
                    sec_protocol_verify_complete(false)
                }
            }
        }, queue)
        
        return NWParameters(tls: options)
    }
}
