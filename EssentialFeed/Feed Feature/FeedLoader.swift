//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Julian Ramkissoon on 12/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case fail(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
