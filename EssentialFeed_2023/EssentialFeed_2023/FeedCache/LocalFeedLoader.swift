//
//  LocalFeedLoader.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/3/23.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage],
                     completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            guard let self = self else { return }
            
            guard cacheDeletionError == nil else {
                completion(cacheDeletionError)
                return
            }
            self.cache(feed, with: completion)
        }
    }
    
    public func load() {
        store.retrieve()
    }
    
    private func cache(_ feed: [FeedImage],
                       with completion: @escaping (SaveResult) -> Void) {
        store.insert(
            feed.toLocal(),
            timestamp: currentDate()) { [weak self] cacheInsertionError in
                guard self != nil else { return }
                completion(cacheInsertionError)
            }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url)
        }
    }
}
