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
    init(_ httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.get(from: URL(string: "anyUrl")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

final class HTTPClientSpy: HTTPClient {
    var requestedUrl: URL?
    func get(from url: URL) {
        requestedUrl = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotCallLoad() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
