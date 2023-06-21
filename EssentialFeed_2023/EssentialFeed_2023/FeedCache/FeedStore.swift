//
//  FeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/3/23.
//

import Foundation


public typealias CachedFeed  = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (FeedStore.RetrievalResult) -> Void
    
    ///  The completion handler can be invoiked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    ///  The completion handler can be invoiked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date,
                completion: @escaping InsertionCompletion)
    
    ///  The completion handler can be invoiked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
