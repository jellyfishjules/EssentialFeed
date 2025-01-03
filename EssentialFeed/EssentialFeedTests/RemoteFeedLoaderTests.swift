//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jules on 03/01/2025.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedUrl: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
    
}
