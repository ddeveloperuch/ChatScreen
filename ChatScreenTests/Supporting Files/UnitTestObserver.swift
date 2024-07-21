//
//  UnitTestObserver.swift
//  ChatScreenTests
//
//  Created by Developer on 20/07/2024.
//  Copyright © 2024 Developer Software Foundation. All rights reserved.
//

import Foundation
import XCTest

let logger = Logger()

class UnitTestObserver: NSObject, XCTestObservation {
    
    public override init() {
        super.init()
        
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        logger.info("Test Suite: \(testSuite.name) {", category: .xctest)
    }
    
    func testCaseWillStart(_ testCase: XCTestCase) {
        logger.info("------------------------------------------------------", category: .xctest)
        logger.info("Test Case: \(testCase.name)", category: .xctest)
    }
    
    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        logger.info("} Test Suite: \(testSuite.name)", category: .xctest)
    }
}
