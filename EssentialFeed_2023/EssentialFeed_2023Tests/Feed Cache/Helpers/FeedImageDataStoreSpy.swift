//
//  FeedImageDataStoreSpy.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 30.12.2023.
//

import Foundation
import EssentialFeed_2023

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
    // The sync API needs to stub the values before the method is invoked because we need to return the values immidiately syncronously
    // Syncronous first strub and then calling the method
}
