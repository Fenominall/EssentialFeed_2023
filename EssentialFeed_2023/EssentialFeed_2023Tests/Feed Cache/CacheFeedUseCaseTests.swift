//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/2/23.
//

import XCTest
import EssentialFeed_2023

class LocalFeedLoad {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

/// The FeedStore is a helper class representing the framework side to help us define the Use Case needs for its collaborator, making sure not to leak framework details into the Use Case.
/// To decouple the application from framework details, we dont let frameworks dicatte the Use Case interfaces (e.g., adding Codable requirements or CoreData managed contexts oarameters). We do so by test-driving the interfaces the Use case needs for its collaborators, rather than defining the interface upfront to facilitate a specific framework implementation.`
class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}


final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeletesCacheUpOnCreation() {
        let store = FeedStore()
        _ = LocalFeedLoad(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoad(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(),
                 description: "descreption",
                 location: "location",
                 imageURL: anyURL())
    }
}
