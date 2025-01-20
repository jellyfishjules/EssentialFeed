//
//  XCTestCaseMemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Jules on 20/01/2025.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, potential memory leak", file: file, line: line)
        }
    }
}
