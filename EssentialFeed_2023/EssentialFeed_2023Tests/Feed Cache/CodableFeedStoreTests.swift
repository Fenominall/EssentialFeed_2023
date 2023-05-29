//
//  CodableFeedStoreTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/12/23.
//

import XCTest
import EssentialFeed_2023

//✅ Retrieve
//    ✅ Empty cache returns empty
//    ✅ Empty cache twice returns empty (no side-effects)
//    ✅ Non-empty cache returns data
//    ✅ Non-empty cache twice returns same data (no side-effects)
//    ✅ Error returns error (if applicable, e.g., invalid data)
//    ✅ Error twice returns same error (if applicable, e.g., invalid data)
//
//✅ Insert
//    ✅ To empty cache stores data
//    ✅ To non-empty cache overrides previous data with new data
//    ✅ Error (if applicable, e.g., no write permission)
//
//✅ Delete
//    ✅ Empty cache does nothing (cache stays empty and does not fail)
//    ✅ Non-empty cache leaves cache empty
//    ✅ Error (if applicable, e.g., no delete permission)
//
//- Side-effects must run serially to avoid race-conditions

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // code is better then commen because the commen can get out of date if you forget update code it`s not possible to compile
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreSideEffects()
        super.tearDown()
    }
    
    // MARK: - Retrieve
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        excpect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        excpect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        excpect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        excpect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        excpect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    // MARK: - Insert
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to inser cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        excpect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertuinError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with error")
    }
    
    // MARK: - Delete
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        
        excpect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        
        excpect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    // MARK: - Side Effects
    func test_storeSideEffetcs_runSerially() {
        let sut = makeSUT()
        var completedOperationInorder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert((uniqueImageFeed().local), timestamp: Date()) { _ in
            completedOperationInorder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationInorder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert((uniqueImageFeed().local), timestamp: Date()) { _ in
            completedOperationInorder.append(op3)
            op1.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationInorder, [op1, op2, op3], "Expected side-ffects to run serially but operation finished in the wrong order")
    }
    

    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath,
                         line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionEror in
            deletionError = receivedDeletionEror
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage],
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
    
    private func excpect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line) {
            excpect(sut, toRetrieve: expectedResult, file: file, line: line)
            excpect(sut, toRetrieve: expectedResult, file: file, line: line)
        }
    
    
    private func excpect(
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
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
