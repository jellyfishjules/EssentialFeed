//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Jules on 28/02/2025.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managedItem = ManagedFeedImage(context: context)
            managedItem.id = local.id
            managedItem.imageDescription = local.description
            managedItem.location = local.location
            managedItem.url = local.url
            return managedItem
        })
    }
    
    var local: LocalFeedImage {
        return  LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
