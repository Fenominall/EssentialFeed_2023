//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 30.12.2023.
//

import XCTest
import EssentialFeed_2023

final class LocalFeedImageDataLoader {
    init(store: Any) {}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
 
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) 
    -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
