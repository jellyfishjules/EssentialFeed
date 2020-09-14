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
        httpClient.requestedUrl = URL(string: "anyURL")
    }
}

final class HTTPClient {
    var requestedUrl: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotCallLoad() {
        let client = HTTPClient()
        _ = RemoteFeedLoader(client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
