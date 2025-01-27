//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 27/01/2025.
//

import XCTest

final class CacheFeedUseCaseTests: XCTestCase {

    class LocalFeedLoader {
        private let store: FeedStore
        
        init(store: FeedStore) {
            self.store = store
        }
    }
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
    }
    
    func test_init_DoesNotCallDeleteCacheOnCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
