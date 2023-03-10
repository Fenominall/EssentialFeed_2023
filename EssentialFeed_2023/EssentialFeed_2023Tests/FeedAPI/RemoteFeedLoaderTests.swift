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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                // dummy json implementation
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: - Checking Success Courses for VALID JSON
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliverFeedItemsOn200HTTPResponseWithValidJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(
            id: UUID(),
            description: "a descreption",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!)
        let itemModels = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(itemModels)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    // Guarantee we do not deliver a result (invoke the completion closure) after the 'RemoteFeedLoader' instance has been deallocated
    func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        // given
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader?  = RemoteFeedLoader(url: makeURL(), client: client)
        var capturedResults = [RemoteFeedLoader.Results]()
        sut?.load(completion: { capturedResults.append($0) })
        
        sut = nil
        // after SUT has been deallocated the client should not complete
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line)
    -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeak(
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
    
    // MARK: - JSON Helpers
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL) ->
    (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL)
        // To avoid typecasting json to as [String : Any] we can use reduce()
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, element) in
            // If we have a value the element it`s added to the dictionary - acc
            if let value = element.value { acc[element.key] = value }
        }
        
        return (item, json )
    }
    
    //Function to group items into a payloud contract
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Results,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            var capturedResults = [RemoteFeedLoader.Results]()
            sut.load { capturedResults.append($0) }
            
            action()
            
            XCTAssertEqual(capturedResults, [result], file: file, line: line)
        }
    
    private func makeURL(_ url: URL
                         = URL(string: "https://a-url.com")!) -> URL {
        return url
    }
    
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requesterURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
