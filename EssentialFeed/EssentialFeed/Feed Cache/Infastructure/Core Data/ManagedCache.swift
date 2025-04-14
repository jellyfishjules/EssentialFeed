//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Jules on 28/02/2025.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed
            .compactMap{ ($0 as? ManagedFeedImage)?.local }
    }
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request: NSFetchRequest<ManagedCache> = NSFetchRequest(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
