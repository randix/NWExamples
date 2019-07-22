//
//  MTSMessageTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class MTSMessageTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: MTSMessage?

    let mockRequest = MockMTSRequest(rawValue: 0)

    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MTSMessage(request: mockRequest,
                             jwt: "",
                             data: Data(capacity: 0))
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    // Composite Test
//    func testSubjectConforms<#protocol#>() { XCTAssert(subject is <#protocol#>) }
}

