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
        
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        })
    }
    
    func test_deliversError_onClientNon200ResponseError() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 400, 500]
        
        statusCodes.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(with: code, at: index)
            })
        }
    }
    
    func test_deliversError_onClient200ResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "anyURL")!) -> (feedLoader: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, httpClient: client), client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        action()

        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
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
            messages[index].completion(.fail(error))
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
