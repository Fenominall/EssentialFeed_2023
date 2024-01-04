//
//  EssentialFeed_2023CacheIntegrationTests.swift
//  EssentialFeed_2023CacheIntegrationTests
//
//  Created by Fenominall on 6/16/23.
//

import XCTest
import EssentialFeed_2023

final class EssentialFeed_2023CacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreSideEffects()
        super.tearDown()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesitemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)

        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
        
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage] ,
        file: StaticString = #file,
        line: UInt = #line) {
            
            let exp = expectation(description: "Wait for load completion")
            sut.load { result in
                switch result {
                case let .success(loadedFeed):
                    XCTAssertEqual(expectedFeed, loadedFeed, "Expected empty feed")
                case let .failure(error):
                    XCTFail("Expected successfull feed result, got \(error) instead")
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
    private func save(
        _ feed: [FeedImage],
        with loader: LocalFeedLoader,
        file: StaticString = #file,
        line: UInt = #line) {
            let saveExp = expectation(description: "Wait for save completion")
            loader.save(feed) { result in
                if case let Result.failure(error) = result {
                    XCTAssertNil(error, "Expected to save fedd successfully")
                }
                saveExp.fulfill()
            }
            wait(for: [saveExp], timeout: 1.0)
            
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
