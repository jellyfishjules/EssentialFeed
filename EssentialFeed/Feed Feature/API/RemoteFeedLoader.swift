//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Julian Ramkissoon on 14/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let httpClient: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Error) -> Void ) {
        httpClient.get(from: url) { (error, response) in
            if error != nil {
                completion(.connectivity)
            } else {
                completion(.invalidData)
            }

        }
    }
}
