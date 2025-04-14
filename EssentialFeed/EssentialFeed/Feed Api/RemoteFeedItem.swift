//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Jules on 10/02/2025.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
