//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 27/01/2025.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    class LocalFeedLoader {
        private let store: FeedStore
        
        init(store: FeedStore) {
            self.store = store
        }
        
        func save(items: [FeedItem]) {
            store.deleteCachedFeed()
        }
    }
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
        
        func deleteCachedFeed() {
            deleteCachedFeedCallCount += 1
        }
    }
    
    func test_init_doesNotCallDeleteCacheOnCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // Helpers: -
    
    private func makeUniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: "", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
