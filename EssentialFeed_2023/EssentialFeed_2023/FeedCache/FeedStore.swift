//
//  FeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/3/23.
//

import Foundation


public typealias CachedFeed  = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}

