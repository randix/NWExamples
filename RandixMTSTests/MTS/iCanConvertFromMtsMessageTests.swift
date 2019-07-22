//
//  iCanConvertFromMtsMessageTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class iCanConvertFromMtsMessageTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: ICanConvertFromMtsMessage?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockICanConvertFromMtsMessage()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    // Function Test
    func testSubjectMethodInjectsDependencies() {
        if let mockReq = OPRequest(rawValue: 1) {
            let data = Data(capacity: 0)
            let mockMsg = MTSMessage(request: mockReq,
                                     jwt: "mockJwt",
                                     data: data)
            let _ = subject?.convert(from: mockMsg)
        } else {
            XCTFail()
        }
    }
}

// MARK: - Structs: Mocks...

struct MockICanConvertFromMtsMessage: ICanConvertFromMtsMessage {
    func convert(from mtsMessage: MTSMessage) -> MTSRequestType {
        return OPError(message: mtsMessage)
    }
}
