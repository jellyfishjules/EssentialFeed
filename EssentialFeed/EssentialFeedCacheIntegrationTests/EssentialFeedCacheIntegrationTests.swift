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
      expect(sut: sut, toLoad: [])
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
        
        expect(sut: sutToPerformLoad, toLoad: feed)
      }
    
    func test_save_overridesItemsSavedOnASeperateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()

        let firstFeed = uniqueImageFeed().models
        let secondFeed = uniqueImageFeed().models

        let firstSaveExp = expectation(description: "waiting for first save completion")
        sutToPerformFirstSave.save(firstFeed) { saveError in
            XCTAssertNil(saveError, "Expected first feed to save successfully")
            firstSaveExp.fulfill()
        }
        wait(for: [firstSaveExp], timeout: 1.0)
        

        let secondSaveExp = expectation(description: "waiting for second save completion")
        sutToPerformSecondSave.save(secondFeed) { saveError in
            XCTAssertNil(saveError, "Expected second feed to save successfully")
            secondSaveExp.fulfill()
        }
        wait(for: [secondSaveExp], timeout: 1.0)
        
        expect(sut: sutToPerformLoad, toLoad: secondFeed)
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
    
    private func expect(sut: FeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "waiting for load completion")
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, expectedFeed)
            case  .failure(let error):
                XCTFail("expected success with empty items, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
