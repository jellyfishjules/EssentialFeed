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
        private let currentDate: () -> Date
        
        init(store: FeedStore, currentDate: @escaping () -> Date) {
            self.store = store
            self.currentDate = currentDate
        }
        
        func save(items: [FeedItem]) {
            store.deleteCachedFeed { [unowned self] error in
                if error == nil {
                    self.store.insert(items, with: self.currentDate())
                }
            }
        }
    }
    
    class FeedStore {
        
        typealias Deletioncompletion = (Error?) -> Void
                
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insertedItems(items: [FeedItem], timestamp: Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletions = [Deletioncompletion]()
        
        func deleteCachedFeed(completion: @escaping Deletioncompletion) {
            receivedMessages.append(.deleteCachedFeed)
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem], with timestamp: Date) {
            receivedMessages.append(.insertedItems(items: items, timestamp: timestamp))
        }
    }
    
    func test_init_doesNotMessageStoreOnCreation() {
        let store = makeSUT().store
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
       
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        
        sut.save(items: items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: {timestamp} )
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insertedItems(items: items, timestamp: timestamp)])
    }
    
    // Helpers: -
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
