//
//  CoreDataFeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 6/12/23.
//

import Foundation
import CoreData


public final class CoreDataFeedStore: FeedStore {
    
    //MARK: - Properties
    private let model = "FeedStore"
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    //MARK: - Initialization
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: model, url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    // MARK: - Methods
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        
        perform { context in
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
        
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        perform { context in
            completion(Result {
                try ManagedCache
                    .find(in: context)
                    .map(context.delete)
                    .map(context.save)
            })
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
