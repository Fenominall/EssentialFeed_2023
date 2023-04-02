//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/1/23.
//

import XCTest

/// Four ways to test the Network:
/// 1.End-to-end test
/// 2. Subclass-URLSession- URLSessionDataTask - problematic and frigle way
/// 3.

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
            .resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https:any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getfromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https:any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCalledCount, 1)
    }
    
    
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
    
        
        override func dataTask(with url: URL,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            // when the production code asks for a task we can return a stub for url or if there is none a fake one
            return stubs[url] ?? FakeURLSessinDataTask()
        }
    }
    
    private class FakeURLSessinDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCalledCount: Int = 0
        
        override func resume() {
            resumeCalledCount += 1
        }
    }
}

