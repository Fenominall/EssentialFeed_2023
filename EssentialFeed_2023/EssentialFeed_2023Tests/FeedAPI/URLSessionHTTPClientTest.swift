//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/1/23.
//

import XCTest
import EssentialFeed_2023

/// Four ways to test the Network:
/// 1.End-to-end test - flaky and requires a backend
/// 2. Subclass-URLSession- URLSessionDataTask - problematic and frigle way to override methods
/// 3. Protocl-based mocking - "With protocols with only care about a specific behaviour"
/// 4.

protocol HTTPSession {
    func dataTask(with url: URL,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask{
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getfromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https:any-url.com")!
        let session = HTTPSessionSpy()
        let task = FakeURLSessionDataTask()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCalledCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https:any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
                
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    // MARK: - Helpers
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error )
        }
        
        
        func dataTask(with url: URL,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for a \(url)")
            }
            // when the production code asks for a task we can return a stub for url or if there is none a fake one
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class HTTPSessionDataTaskSpy: HTTPSessionTask {
        func resume() {}
    }
    private class FakeURLSessionDataTask: HTTPSessionTask {
        var resumeCalledCount: Int = 0
        
        func resume() {
            resumeCalledCount += 1
        }
    }
}

