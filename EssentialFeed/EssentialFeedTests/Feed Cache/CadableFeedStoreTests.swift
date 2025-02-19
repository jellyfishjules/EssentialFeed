//
//  CadableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 19/02/2025.
//

import XCTest
import EssentialFeed

private class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }

}

final class CadableFeedStoreTests: XCTestCase {

  
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retreival")
        sut.retrieve { result in
        
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
}
