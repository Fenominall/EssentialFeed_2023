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
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(
                        .success(CachedFeed(
                        feed: cache.localFeed,
                        timestamp: cache.timestamp)))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        perform { context in
            do {
                try ManagedCache
                    .find(in: context)
                    .map(context.delete)
                    .map(context.save)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
