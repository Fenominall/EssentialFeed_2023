//
//  FeedStoreSpecs.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/29/23.
//

import Foundation
//
//It’s not advised to use class inheritance to reuse/share code and functionality. Class inheritance is better used to extend functionality (additive changes to an existing implementation).
//
//To reuse/share functionality, composition is often a better choice. That’s where the famous “Prefer composition over inheritance” quote comes from (aka Composite Reuse Principle).
//
//Class composition is achieved by containing other classes (e.g., as properties) that implement the desired functionality, rather than relying on inheritance (subclassing) for sharing functionality.
//
//Furthermore, in Swift, class composition through inheritance is not possible because a class can only inherit from one class.

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()
    
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    
    func test_storeSideEffetcs_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
