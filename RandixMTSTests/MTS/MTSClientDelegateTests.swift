//
//  MTSClientDelegateTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class MTSClientDelegateTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: MTSClientDelegate?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockClientDelegate()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    func testConnectMethodInjectsDependencies() {
        let _ = subject?.mtsConnect()
    }
    
    func testDisconnectMethodInjectsDependencies() {
        let _ = subject?.mtsDisconnect()
    }
    
    func testReceiveMethodInjectsDependencies() {
        let mock = MockMTSRequest(rawValue: 0)
        let msg = MTSMessage(request: mock,
                             jwt: "",
                             data: Data(capacity: 0))
        let _ = subject?.mtsReceive(msg)
    }
}

// MARK: - Structs: Mocks...

struct MockClientDelegate: MTSClientDelegate {
    func mtsConnect() { }
    
    func mtsDisconnect() { }
    
    func mtsReceive(_ mtsMessage: MTSMessage) { }
}
