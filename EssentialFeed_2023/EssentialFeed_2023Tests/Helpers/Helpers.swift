//
//  Helpers.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/8/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
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
}
