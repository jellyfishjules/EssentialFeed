//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Julian Ramkissoon on 14/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotCallLoad() {
        let client = makeSUT().client
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_deliversError_onClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        })
    }
    
    func test_deliversError_onClientNon200ResponseError() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 400, 500]
        
        statusCodes.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(with: code, at: index)
            })
        }
    }
    
    func test_deliversError_onClient200ResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }
    
    func test_deliversNoItems_onClient200ResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyListJSON)
        })
    }
    
    func test_deliversItems_onClient200ResponseWithValidJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "http://anyUrl.com")!)
        
        let item1JSON: [String : Any] = ["id": item1.id.uuidString,
                                         "image": item1.imageURL.absoluteString]
        
        let item2 = FeedItem(id: UUID(),
                             description: "some description",
                             location: "some location",
                             imageURL: URL(string: "http://anotherUrl.com")!)
        
        let item2JSON: [String : Any] = ["id": item2.id.uuidString,
                                         "description": item2.description!,
                                         "location": item2.location!,
                                         "image": item2.imageURL.absoluteString]
        
        let itemsJSON = ["items": [item1JSON, item2JSON]]
        
           expect(sut, toCompleteWithResult: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
               client.complete(with: 200, data: json)
           })
       }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "anyURL")!) -> (feedLoader: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, httpClient: client), client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.RemoteFeedLoaderResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.RemoteFeedLoaderResult]()
        sut.load { capturedResults.append($0) }
        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedUrls: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
