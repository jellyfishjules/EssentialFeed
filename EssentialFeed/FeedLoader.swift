//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Julian Ramkissoon on 12/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case fail(Error)
}

protocol FeedLoader {
    func loadItems(completion: @escaping (LoadFeedResult) -> Void)
}
