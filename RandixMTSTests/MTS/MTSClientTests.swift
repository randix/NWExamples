//
//  IMTSClientTests.swift
//  OnityCommsTests
//
//  Created by UTC Mobile Dev on 6/12/19.
//  Copyright © 2019 UTC.onity. All rights reserved.
//

import XCTest

class MTSClientTests: XCTestCase {
    
    // MARK: - Properties
    
    // MARK: - Properties: Subjects, Mocks & Stubs...
    
    var subject: MTSClient?
    
    // MARK: - Functions
    
    // MARK: - Functions: XCTestCase
    
    override func setUp() {
        subject = MockMTSClient()
    }
    
    override func tearDown() {
        subject = nil
    }
    
    // MARK: - Functions: Unit Tests...
    
    func testSubjectExists() { XCTAssertNotNil(subject) }
    
    func testSubjectHasMTSDataModel() {
        XCTAssert(subject?.mtsModel is MTSDataModel)
    }
    
    func testSubjectHasMTSClientDelegate() {
        XCTAssert(subject?.delegate is MTSClientDelegate)
    }
    
    func testSubjectHasPort() {
        XCTAssert(subject?.port is UInt16)
    }
    
    func testSubjectHasHost() {
        XCTAssert(subject?.host is String)
    }
    
    func testSubjectCanStateChange() {
        XCTAssert(subject is ICanStateChange)
    }
}

// MARK: - Structs: Mocks...

public class MockMTSClient: MTSClient {
    public var requestedObj: MTSRequestType?
    
    public var await = DispatchSemaphore(value: 0)
    
    public var isWaiting = false
    
    public var expected = 0
    
    public var buffer = Data()
    
    public var isNeedsConnectionKilled = false    
    
    public func log(_ msg: String) {
        
    }
    
    public func mtsConnect() {
        
    }
    
    public func mtsDisconnect() {
        
    }
    
    public func mtsReceive(_ mtsMessage: MTSMessage) {
        
    }
    
    
    public var mtsModel = MTSDataModel()
    
    public var delegate: MTSClientDelegate? = MockMTSClientDelegate()
    
    public let port: UInt16 = 0
    
    public let host: String = ""
}

struct MockMTSClientDelegate: MTSClientDelegate {
    func mtsConnect() { }
    
    func mtsDisconnect() { }
    
    func mtsReceive(_ mtsMessage: MTSMessage) { }
}
