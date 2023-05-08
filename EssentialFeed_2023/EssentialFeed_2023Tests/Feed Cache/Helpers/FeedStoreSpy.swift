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
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.inser(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
    }
}
