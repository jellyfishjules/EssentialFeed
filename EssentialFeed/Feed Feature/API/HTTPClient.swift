//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Julian Ramkissoon on 14/09/2020.
//  Copyright © 2020 jellyfishapps. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case failure(Error)
    case success(Data, HTTPURLResponse)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
