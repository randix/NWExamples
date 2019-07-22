//
//  IMTSInteractorTests.swift
//  SFF_Portable_ProgrammerTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class IMTSInteractorTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: IMTSInteractor?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockMTSInteractor()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
}

protocol IMTSInteractor {
    
}

struct MockMTSInteractor: IMTSInteractor {
    
}
