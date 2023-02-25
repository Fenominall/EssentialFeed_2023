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
        
        sut.load()
        
        XCTAssertEqual(client.requesterURLs, [url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    
    // we need to test how many times the method(the client behaviour) was invoked
    func test_loadTwice_requestsDataFromURL() {
        let url = makeURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requesterURLs, [url, url])
    }

    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        
        var requesterURLs = [URL]()
        var error: Error?
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requesterURLs.append(url)
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
