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
    func insert(_ feed: [LocalFeedImage], with timestamp: Date, completion: @escaping Insertioncompletion)
    func retrieve()
}
