//
//  FeedImagePresenterTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 11/24/23.
//

import XCTest
import EssentialFeed_2023

public final class FeedImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}


final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageTheViewUpOnCreation() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
    
    
}
