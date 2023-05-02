//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/2/23.
//

import XCTest


class LocalFeedLoad {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

// The FeedStore is a helper class representing the framework side to help us define the Use Case needs for its collaborator, making sure not to leak framework details into the Use Case.
class FeedStore {
    var deleteCachedFeedCallCount = 0
}


final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeletesCacheUpOnCreation() {
        let store = FeedStore()
        _ = LocalFeedLoad(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
