//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
	public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = url
    }
}
