//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Jules on 25/03/2025.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

  func test_load_deliversNoItemsOnEmptyCache() {
      let sut = makeSUT()
      
      let exp = expectation(description: "waiting for load completion")
      sut.load { result in
          switch result {
          case .success(let items):
              XCTAssertEqual(items, [])
          case  .failure(let error):
              XCTFail("expected success with empty items, got \(error) instead")
          }
          
          exp.fulfill()
      }
      wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = testSpecificStoreUrl()
        let store = try! CoreDataFeedStore(storeURL: storeUrl, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return LocalFeedLoader(store: store, currentDate: Date.init)
    }

    private func testSpecificStoreUrl() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
