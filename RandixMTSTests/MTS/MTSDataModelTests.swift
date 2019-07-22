//
//  MTSDataModelTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/16/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class MTSDataModelTests: XCTestCase {

    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: MTSDataModel?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MTSDataModel()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    func testSubjectHasUser() { XCTAssert(subject?.user is String) }
    
    func testSubjectHasPass() { XCTAssert(subject?.pass is String) }
    
    func testSubjectHasUsingTls() {
        XCTAssert(subject?.isUsingTls is Bool)
    }
    
    func testSubjectHasJWT() {
        XCTAssert(subject?.jwt is String?)
    }
    
    func testSubjectHasIsConnected() {
        XCTAssertNotNil(subject?.isConnected)
    }
}
