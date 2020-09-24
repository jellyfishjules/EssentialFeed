//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Julian Ramkissoon on 12/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
