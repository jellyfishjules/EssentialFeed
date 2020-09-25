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
    
    public enum RemoteFeedLoaderResult: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (RemoteFeedLoaderResult) -> Void ) {
        httpClient.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    private struct Root: Decodable {
        let items: [Item]
    }
    
    static private var STATUS_OK: Int {
        return 200
    }
    
    static func map(_ data: Data, _ resppnse: HTTPURLResponse) throws -> [FeedItem] {
        guard resppnse.statusCode == STATUS_OK else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root =  try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.feedItem }
    }
}


