//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 12/3/23.
//

import EssentialFeed_2023
import XCTest

final class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapperd: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapperd?.cancel()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result
    ) -> Void) -> FeedImageDataLoaderTask {
        // The result passed in task.complere(with:) will be passed from the HTTPClientTaskWrapper to the completion of loadImageData() because completion in the class is the reference type
        let task = HTTPClientTaskWrapper(completion)
        task.wrapperd = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        return task
    }
}


final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(clientError), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let cleint = HTTPClinetSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: cleint)
        
        var capturedResult = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL(), completion: { capturedResult.append($0) })
        
        sut = nil
        cleint.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClinetSpy) {
        let client = HTTPClinetSpy()
        let presenter = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, client)
    }
    
    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let url = URL(string: "https://a-given-url.com")!
            let exp = expectation(description: "Wait for load completion")
            
            sut.loadImageData(from: url) { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Expected result \(expectedResult) got \(receivedResult) insted", file: file, line: line)
                }
                exp.fulfill()
            }
            
            action()
            wait(for: [exp], timeout: 2.0)
        }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
}

