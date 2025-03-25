//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Jules on 25/03/2025.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
            super.setUp()

            setupEmptyStoreState()
        }

        override func tearDown() {
            super.tearDown()

            undoStoreSideEffects()
        }

    
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
    
    func test_load_deliversItemsSavedOnASeperateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()

        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "waiting for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected feed to save successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
      
        
        let loadExp = expectation(description: "waiting for load completion")
        sutToPerformLoad.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, feed)
            case  .failure(let error):
                XCTFail("expected success with empty items, got \(error) instead")
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
      }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeUrl, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return LocalFeedLoader(store: store, currentDate: Date.init)
    }

    private func setupEmptyStoreState() {
            deleteStoreArtifacts()
        }

        private func undoStoreSideEffects() {
            deleteStoreArtifacts()
        }

        private func deleteStoreArtifacts() {
            try? FileManager.default.removeItem(at: testSpecificStoreURL())
        }
    private func testSpecificStoreURL() -> URL {
            return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        }

        private func cachesDirectory() -> URL {
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }
}
