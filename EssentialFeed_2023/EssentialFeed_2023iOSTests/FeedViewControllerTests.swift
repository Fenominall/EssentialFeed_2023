//
//  FeedViewControllerTests.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 6/28/23.
//

import XCTest

public final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {}
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}


