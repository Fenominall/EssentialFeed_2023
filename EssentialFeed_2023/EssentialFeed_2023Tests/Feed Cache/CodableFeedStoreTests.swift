//
//  CodableFeedStoreTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/12/23.
//

import XCTest
import EssentialFeed_2023

//- Retrieve
//    ✅ Empty cache returns empty
//    - Empty cache twice returns empty (no side-effects)
//    - Non-empty cache returns data
//    - Non-empty cache twice returns same data (no side-effects)
//    - Error returns error (if applicable, e.g., invalid data)
//    - Error twice returns same error (if applicable, e.g., invalid data)
//
//- Insert
//    - To empty cache stores data
//    - To non-empty cache overrides previous data with new data
//    - Error (if applicable, e.g., no write permission)
//
//- Delete
//    - Empty cache does nothing (cache stays empty and does not fail)
//    - Non-empty cache leaves cache empty
//    - Error (if applicable, e.g., no delete permission)
//
//- Side-effects must run serially to avoid race-conditions

public final class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}


final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyCacheonEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empy result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
