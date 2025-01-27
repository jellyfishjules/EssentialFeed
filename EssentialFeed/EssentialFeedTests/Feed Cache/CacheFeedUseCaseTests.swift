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
            store.deleteCachedFeed { [unowned self] error in
                if error == nil {
                    self.store.insert(items)
                }
            }
        }
    }
    
    class FeedStore {
        
        typealias Deletioncompletion = (Error?) -> Void
        
        var deleteCachedFeedCallCount = 0
        var insertCallCount = 0
        private var deletionCompletions = [Deletioncompletion]()
        
        func deleteCachedFeed(completion: @escaping Deletioncompletion) {
            deleteCachedFeedCallCount += 1
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem]) {
            insertCallCount += 1
        }
    }
    
    func test_init_doesNotCallDeleteCacheOnCreation() {
        let store = makeSUT().store
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
       
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        
        sut.save(items: items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // Helpers: -
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)

        return(sut, store)
    }
    
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
