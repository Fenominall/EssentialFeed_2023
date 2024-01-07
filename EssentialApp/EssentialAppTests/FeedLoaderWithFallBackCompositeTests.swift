//
//  RemoteWithFallBackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Fenominall on 05.01.2024.
//

import XCTest
import EssentialFeed_2023

class FeedLoaderWithFallBackComposite: FeedLoader {
    
    private let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallBackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line) -> FeedLoader {
            let primaryLoader = LoaderStub(result: primaryResult)
            let fallbackLoader = LoaderStub(result: fallbackResult)
            let sut = FeedLoaderWithFallBackComposite(primary: primaryLoader, fallback: fallbackLoader)
            trackForMemoryLeaks(primaryLoader, file: file, line: line)
            trackForMemoryLeaks(fallbackLoader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return sut
        }
    
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(
                    instance, "Instance should have been deallocated. Potenially memory leak",
                    file: file,
                    line: line)
            }
        }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http:/any-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
