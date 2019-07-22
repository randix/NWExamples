//
//  ICanLogTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class ICanLogTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: ICanLog?
    
    let mockMsg = "Mock Msg"
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockLogger()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    // Function Test
    func testSubjectMethodInjectsDependencies() {
        subject?.log(mockMsg)
    }
}

// MARK: - Structs: Mocks...

struct MockLogger: ICanLog {
    func log(_ msg: String) {
        print("Mock Loggy: \(msg)")
    }
}
