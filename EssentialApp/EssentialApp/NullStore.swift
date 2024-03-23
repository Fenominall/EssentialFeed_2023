//
//  NullStore.swift
//  EssentialApp
//
//  Created by Владислав Тодоров on 29.02.2024.
//

import Foundation
import EssentialFeed_2023

class NullStore: FeedStore {
    func deleteCachedFeed() throws {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    func retrieve() throws -> CachedFeed? { .none }
}

extension NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
