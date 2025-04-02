//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Jules on 25/02/2025.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversFailureOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), into: sut)
        
        XCTAssertNotNil(insertionError, "Expected insertion to fail with an error")    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((feed: uniqueImageFeed().local, timestamp: Date()), into: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
}
