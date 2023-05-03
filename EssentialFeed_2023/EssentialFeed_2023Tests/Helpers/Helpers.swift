//
//  Helpers.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/8/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(
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
    
    func anyURL() -> URL {
        return URL(string: "https:any-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error",
                       code: 1)
    }
    
    func anyData() -> Data {
        return Data("invalid json".utf8)
    }
}
