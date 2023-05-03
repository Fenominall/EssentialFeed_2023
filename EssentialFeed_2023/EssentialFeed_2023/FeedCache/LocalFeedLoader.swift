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
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.insert(
                    items, timestamp: self.currentDate(),
                    completion: completion)
            } else {
                completion(error)
            }
        }
    }
}
