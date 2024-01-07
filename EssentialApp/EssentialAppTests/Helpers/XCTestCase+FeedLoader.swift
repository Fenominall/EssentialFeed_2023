//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Fenominall on 07.01.2024.
//

import EssentialFeed_2023
import XCTest


protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader,
                toCompleteWith expectedResult: FeedLoader.Result,
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead",
                        file: file,
                        line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
