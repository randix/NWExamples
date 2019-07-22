//
//  ICanConvertFromDataTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class ICanConvertFromDataTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: ICanConvertFromData?
    
    let mockData = Data(capacity: 0)

    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockICanConvertFromData()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    func testSubjectMethodInjectsDependencies() {
        let _ = subject?.convert(from: mockData)
    }
    
    func testSubjectMethodReturnsMTSMessage() {
        let msg = subject?.convert(from: mockData)
        XCTAssert(msg is MTSMessage)
    }
}

// MARK: - Structs: Mocks...

struct MockICanConvertFromData: ICanConvertFromData {
    func log(_ msg: String) { MockLogger().log(msg) }
}


protocol ICanConvertFromData: ICanLog { }

extension ICanConvertFromData {
    
    // TODO: !!
     
      /// <#definition#>
      ///
      /// - parameter <#title#>: <#description#>
      /// - returns: <#description#>
      
    func convert(from data: Encodable) -> MTSMessage? {
//
//        log(" Converting from: \(data) ")
//        let encoded = JSONEncoder().encode(data)
//
//        return MTSMessage(request: <#T##MTSRequest#>, jwt: <#T##String#>, data: <#T##Data#>)
        return nil
    }
}
