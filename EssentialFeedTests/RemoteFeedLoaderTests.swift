//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Julian Ramkissoon on 14/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import XCTest

final class RemoteFeedLoader{
    let httpClient: HTTPClient
    let url: URL
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}



final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotCallLoad() {
        let client = makeSUT().client
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "anyURL")!) -> (feedLoader: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, httpClient: client), client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?
        
        func get(from url: URL) {
            requestedUrl = url
        }
    }
}
