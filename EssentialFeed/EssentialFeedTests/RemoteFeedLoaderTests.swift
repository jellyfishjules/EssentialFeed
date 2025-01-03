//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 03/01/2025.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://example.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
        
    func get(from url: URL) { }
}

class HTTPClientSpy: HTTPClient {
    var requestedUrl: URL?
    
    override func get(from url: URL) {
        requestedUrl = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsDataFromUrl() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client

        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
