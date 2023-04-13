//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 4/1/23.
//

import XCTest
import EssentialFeed_2023
//import Foundation

/// Four ways to test the Network:
/// 1.End-to-end test - flaky and requires a backend
/// 2. Subclass-URLSession- URLSessionDataTask - problematic and frigle way to override methods
/// 3. Protocl-based mocking - "With protocols with only care about a specific behaviour"
/// 4. URLProtocol stubbing - Subclassing URLProtocol: NSObjcet

final class URLSessionHTTPClientTest: XCTestCase {
    
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // we the same tecnique we can test other requests such as "POST" and etc...
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        var receivedRequests = [URLRequest]()
        URLProtocolStub.observeRequest { request in
            receivedRequests.append(request)
        }
        
        makeSUT().get(from: url) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequests.count, 1)
        XCTAssertEqual(receivedRequests.first?.url, url)
        XCTAssertEqual(receivedRequests.first?.httpMethod, "GET")
    }
    
    func test_getFromURL_failsOnRequestError() {
        let receivedError = resultErrorFor(data: nil, response: nil, error: anyNSError())
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    
    // MARK: - Helpers
    // when your helper functions contain assertions, make sure to pass the file and line arguments to the helper function, so you can forward it as arguments to any XCTAssert... calls. This way, Xcode can highlight the appropriate line of code that was responsible for test failures.
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> Error? {
            let result = resultFor(data: data,
                                   response: response,
                                   error: error,
                                   file: file,
                                   line: line)
            
            var receivedError: Error?
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
                return nil
            }
            return receivedError
        }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
            let result = resultFor(data: data,
                                   response: response,
                                   error: error,
                                   file: file,
                                   line: line)
            
            var receivedValues: (data: Data, response: HTTPURLResponse)?
            switch result {
            case let .success((receivedData, receivedResponse)):
                receivedValues = (receivedData, receivedResponse)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
                return nil
            }
            return receivedValues
        }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> HTTPClientResult {
            URLProtocolStub.stub(data: data, response: response, error: error)
            let sut = makeSUT(file: file, line: line)
            let exp = expectation(description: "Wait for completion")
            
            var receivedResult: HTTPClientResult!
            sut.get(from: anyURL()) { result in
                receivedResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
            return receivedResult
        }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error",
                       code: 1)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https:any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("invalid json".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
    }
    
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        // Capturing the URLRequest to check the URL and the method
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
