//
//  CodableFeedStoreTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/12/23.
//

import XCTest
import EssentialFeed_2023

//- Retrieve
//    ✅ Empty cache returns empty
//    ✅ Empty cache twice returns empty (no side-effects)
//    ✅ Non-empty cache returns data
//    ✅ Non-empty cache twice returns same data (no side-effects)
//    - Error returns error (if applicable, e.g., invalid data)
//    - Error twice returns same error (if applicable, e.g., invalid data)
//
//- Insert
//    ✅ To empty cache stores data
//    - To non-empty cache overrides previous data with new data
//    - Error (if applicable, e.g., no write permission)
//
//- Delete
//    - Empty cache does nothing (cache stays empty and does not fail)
//    - Non-empty cache leaves cache empty
//    - Error (if applicable, e.g., no delete permission)
//
//- Side-effects must run serially to avoid race-conditions

public final class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    //    Move 'Codeable' conformance from the framework-agnostic 'LocalFeedImage'  type to the new framework-specific 'CodableFeedImage' type. The 'CodeableFeedImage' is a private type within the framework implementation since the 'Codable' requirement is a framework-specific detail.
    // In this case the DTO with a mapping used instead.
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.imageURL = image.imageURL
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(
                id: id,
                description: description,
                location: location ,
                url: imageURL)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date,
                completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init),
                          timeStamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
    
}


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
    
    func test_retrieve_deliversEmptyCacheonEmptyCache() {
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
        
        excpect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath,
                         line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func excpect(
        _ sut: CodableFeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line) {
            excpect(sut, toRetrieve: expectedResult, file: file, line: line)
        }
    
    private func insert(_ cache: (feed: [LocalFeedImage],
                                  timestamp: Date),
                        to sut: CodableFeedStore) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func excpect(
        _ sut: CodableFeedStore,
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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
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
