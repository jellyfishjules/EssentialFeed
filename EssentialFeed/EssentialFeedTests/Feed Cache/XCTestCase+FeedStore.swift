//
//  XCTestCase+FeedStore.swift
//  EssentialFeedTests
//
//  Created by Jules on 25/02/2025.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrievedeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), into: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertThatRetrievehasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), into: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().local, Date()), into: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), into: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), into: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCachedValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstInsertionError = insert((feed: uniqueImageFeed().local, timestamp:  Date()), into: sut)
        XCTAssertNil(firstInsertionError, "Expected successful insertion")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((feed: latestFeed, timestamp: latestTimestamp), into: sut)
        XCTAssertNil(latestInsertionError, "Expected successful insertion")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed without an error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatDeleteEmptiesPreviosulyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((feed: uniqueImageFeed().local, timestamp: Date()), into: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed without an error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperations = [XCTestExpectation]()
        
        let exp1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, with: Date()) { _ in
            completedOperations.append(exp1)
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperations.append(exp2)
            exp2.fulfill()
        }
        
        let exp3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, with: Date()) { _ in
            completedOperations.append(exp3)
            exp3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(completedOperations, [exp1, exp2, exp3], "Expected operations to run serially")
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult) {
                
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), into sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, with: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var deletionError: Error?
        sut.deleteCachedFeed() { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
}
