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
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
      
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError, at: 0)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_deliversError_onClientNon200ResponseError() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 400, 500]
        
        statusCodes.enumerated().forEach { (index, code) in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(with: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
        
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "anyURL")!) -> (feedLoader: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, httpClient: client), client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var requestedUrls: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int) {
            messages[index].completion(error, nil)
        }
        
        func complete(with statusCode: Int, at index: Int) {
            let response = HTTPURLResponse(url: requestedUrls[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
}
