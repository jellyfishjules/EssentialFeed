//
//  CadableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 19/02/2025.
//

import XCTest
import EssentialFeed

private class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(_ storeURL: URL) {
        self.storeURL = storeURL
    }
   
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], with timestamp: Date, completion: @escaping FeedStore.InsertionCompletion)
    {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CadableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
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
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retreival")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retreival")
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        sut.insert(feed, with: timestamp) { insertionError in
            
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { result in
            
                switch result {
                case let.found(retreivedFeed, retreivedTimestamp):
                    XCTAssertEqual(retreivedFeed, feed)
                    XCTAssertEqual(retreivedTimestamp, timestamp)

                    
                default:
                    XCTFail("Expected found result with  \(feed), got \(result) instead")
                }
                exp.fulfill()
            }
        }
        
       
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // Helpers: -
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func storeURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    }
}
