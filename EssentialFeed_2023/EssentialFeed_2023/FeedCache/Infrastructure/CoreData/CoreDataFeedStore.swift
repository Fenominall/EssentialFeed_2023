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
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        feed: cache.feed
                            .compactMap { $0 as? ManagedFeedImage }
                            .map{
                                LocalFeedImage(
                                    id: $0.id,
                                    description: $0.imageDescription,
                                    location: $0.location,
                                    url: $0.url)
                            },
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [EssentialFeed_2023.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = NSOrderedSet(array: feed.map { local in
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.id = local.id
                    managedFeedImage.imageDescription = local.description
                    managedFeedImage.location = local.location
                    managedFeedImage.url = local.imageURL
                    return managedFeedImage
                })
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
