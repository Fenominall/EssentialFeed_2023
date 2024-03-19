//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 04.01.2024.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    // MARK: - Methods
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        performAsync { context in
            // with the Result there is no need to use doctach block as well as we do not need to invoke the completion because it wraps returned values in a success case
            // catching parameter name can be ommited
            completion(Result {
                // by mapping the optional returned value we can eleminate if/else
                // name parameter can be ommited by using $0
                try ManagedCache.find(in: context).map {
                    CachedFeed(
                        feed: $0.localFeed,
                        timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        performAsync { context in
            completion(Result {
                try ManagedCache
                    .deleteCache(in: context)
            })
        }
    }
    
}
