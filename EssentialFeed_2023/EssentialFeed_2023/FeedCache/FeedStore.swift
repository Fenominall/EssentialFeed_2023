//
//  FeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/3/23.
//

import Foundation


public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}