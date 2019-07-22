//
//  MTSRequestTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class MTSRequestTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: MTSRequest?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockMTSRequest()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    func testSubjectConformsCanConvertFromMts() { XCTAssert(subject is ICanConvertFromMtsMessage) }
}

// MARK: - Structs: Mocks...

struct MockMTSRequest: MTSRequest {
    
    // MARK: - Properties
    
    // MARK: - Properties: MTSRequest
    
    var rawValue: Int = 0

    // MARK: - Functions
    
    // MARK: - Functions: ICanConvertFromMtsMessage
    
    func convert(from mtsMessage: MTSMessage) -> MTSRequestType {
        return OPError(message: mtsMessage)
    }
    
    // MARK: - Functions: ICanLog
    
    func log(_ msg: String) {
        return MockLogger().log(msg)
    }
}
