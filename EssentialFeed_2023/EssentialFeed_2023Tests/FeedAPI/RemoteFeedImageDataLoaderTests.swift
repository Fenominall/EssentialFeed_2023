//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 12/3/23.
//

import EssentialFeed_2023
import XCTest

final class RemoteFeedImageDataLoader {
    init(client: Any) {}
}


final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requesterURLs.isEmpty)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let presenter = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, client)
    }
        
    private final class HTTPClinetSpy {
        var requesterURLs = [URL]()
    }
}

