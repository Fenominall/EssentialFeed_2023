//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/29/23.
//

import XCTest
import EssentialFeed_2023

// We constrain the protocol extension to XCTestCase subclasses since the helpers use XCTestCase methods.
// Also, it serves as documentation, denoting this protocol extension is for tests only!
extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionEror in
            deletionError = receivedDeletionEror
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage],
                                  timestamp: Date),
                        to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache retrieval")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    func excpect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line) {
            excpect(sut, toRetrieve: expectedResult, file: file, line: line)
            excpect(sut, toRetrieve: expectedResult, file: file, line: line)
        }
    
    
    func excpect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let exp = expectation(description: "Wait for cache retrieval")
            
            sut.retrieve { retrieveResult in
                switch (expectedResult, retrieveResult) {
                case (.empty, .empty),
                    (.failure, .failure):
                    break
                case let (.found(expectedFeed, expectedTimestamp), .found(retrieviedFeed, retrievedTimestamp)):
                    XCTAssertEqual(retrieviedFeed, expectedFeed, file: file, line: line)
                    XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                default:
                    XCTFail("Expected to retrieve \(expectedResult), got \(retrieveResult) instead", file: file, line: line)
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
}
