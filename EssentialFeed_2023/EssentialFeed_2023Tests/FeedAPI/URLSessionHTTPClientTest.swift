//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/1/23.
//

import XCTest

/// Four ways to test the Network:
/// 1.End-to-end test
/// 2. Subclass-

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    func test_getfromURL_createsDataTaskWithURL() {
        let url = URL(string: "https:any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessinDataTask()
        }
    }
    
    private class FakeURLSessinDataTask: URLSessionDataTask {
        
    }
}
