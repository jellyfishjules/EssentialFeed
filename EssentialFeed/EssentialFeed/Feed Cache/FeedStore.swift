//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jules on 04/02/2025.
//

import Foundation

public protocol FeedStore {
    typealias Deletioncompletion = (Error?) -> Void
    typealias Insertioncompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping Deletioncompletion)
    func insert(_ items: [LocalFeedItem], with timestamp: Date, completion: @escaping Insertioncompletion)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
