//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 2/21/23.
//

import XCTest
import EssentialFeed_2023

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requesterURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = makeURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requesterURLs, [url])
    }
    
    // we need to test how many times the method(the client behaviour) was invoked
    func test_loadTwice_requestsDataFromURL() {
        let url = makeURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requesterURLs, [url, url])
    }

    // MARK: - Checking Error Courses
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let invalidJSON = Data("invalidJSON".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    // MARK: - Helpers
    // It`s better to implement the Spy by just capturing the values
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [
            (url: URL,
             completion: (HTTPClientResult) -> Void)]()
        var requesterURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requesterURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!)
    -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    
    private func makeURL(_ url: URL
                         = URL(string: "https://a-url.com")!) -> URL {
        return url
    }
}
