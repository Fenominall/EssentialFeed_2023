//
//  FeedStoreSpy.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/8/23.
//

import Foundation
import EssentialFeed_2023


// The FeedStore is a helper class representing the framework side to help us define the Use Case needs for its collaborator, making sure not to leak framework details into the Use Case.
// To decouple the application from framework details, we dont let frameworks dicatte the Use Case interfaces (e.g., adding Codable requirements or CoreData managed contexts oarameters). We do so by test-driving the interfaces the Use case needs for its collaborators, rather than defining the interface upfront to facilitate a specific framework implementation.`
class FeedStoreSpy: FeedStore {
    
    // Unsing enum for testing to guarantee ate the same time which messages were invoiked with which values and in which order
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case inser([LocalFeedImage], Date)
        case retrieve
    }
    
    private (set) var receivedMessages = [ReceivedMessages]()
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionResult = .success(())
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.inser(feed, timestamp))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func retrieve() throws -> CachedFeed? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(
        with feed: [LocalFeedImage],
        timestamp: Date,
        at index: Int = 0) {
            retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
        }
}
