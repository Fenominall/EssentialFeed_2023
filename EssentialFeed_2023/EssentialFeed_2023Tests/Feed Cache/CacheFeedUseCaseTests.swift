//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/2/23.
//

import XCTest
import EssentialFeed_2023

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        store.completeDeletion(with: deletionError)
        try? sut.save(uniqueImageFeed().models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfullDeletion() {
        let timestamp = Date()
        let feed = uniqueImageFeed()
        let (sut,store) = makeSUT(currentDate: { timestamp })
        
        store.completeDeletionSuccessfully()
        try? sut.save(feed.models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .inser(feed.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        excpect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        excpect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let (sut,store) = makeSUT()
        
        excpect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func excpect(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            action()
            
            do {
                try sut.save(uniqueImageFeed().models)
            } catch  {
                XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
            }
        }
}
