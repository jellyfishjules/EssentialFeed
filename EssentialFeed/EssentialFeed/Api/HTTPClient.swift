//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jules on 08/01/2025.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
