//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 04.01.2024.
//

import XCTest
import EssentialFeed_2023

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http:/a-url.com")!
        let nonMatchingURL = URL(string: "http:/another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL () {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http:/a-url.com")!
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue () {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http:/a-url.com")!
        
        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }
    
    // MARK - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private typealias RetrievalResult = Result<Data?, Error>
    
    private func notFound() -> RetrievalResult {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> RetrievalResult {
        return .success(data)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func  expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrievalWith expectedResult: RetrievalResult,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line) {
            let receivedResult = Result { try sut.retrieve(dataForURL: url) }
            
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }
        }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #filePath,
        line: UInt = #line) {
            do {
                let image = localImage(url: url)
                try sut.insert([image], timestamp: Date())
                try sut.insert(data, for: url)
            } catch {
                XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
            }
        }
}
