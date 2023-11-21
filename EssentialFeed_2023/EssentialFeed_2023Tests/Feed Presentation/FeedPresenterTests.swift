//
//  FeedPresenterTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 11/21/23.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssert(view.messages.isEmpty, "Expected no view messages.")
    }
    
    
    // MARK: - Helpers
    private class ViewSpy {
        let messages = [Any]()
    }
}
