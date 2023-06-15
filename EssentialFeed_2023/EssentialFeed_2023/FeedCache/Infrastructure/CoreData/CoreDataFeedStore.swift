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
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    //MARK: - Initialization
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    // MARK: - Methods
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context  = self.context
        
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(
                        feed: cache.localFeed,
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed =
                ManagedFeedImage.images(from: feed,
                                        in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
