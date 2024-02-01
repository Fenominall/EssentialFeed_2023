//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 2/21/23.
//

import XCTest
import EssentialFeed_2023

final class FeedItemsMapperTests: XCTestCase {
    
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 404, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper
                    .map(json,
                         from: HTTPURLResponse(statusCode: code)))
        }
    }
                
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalidJSON".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper
                .map(invalidJSON,
                     from: HTTPURLResponse(statusCode: 200)))
    }
    
    // MARK: - Checking Success Courses for VALID JSON
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyList() throws {
        let emptyJSON = makeItemsJSON([])
        
        let result = 
        try FeedItemsMapper
            .map(emptyJSON,
                 from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliverFeedItemsOn200HTTPResponseWithValidJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(
            id: UUID(),
            description: "a descreption",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!)
        
        let json = makeItemsJSON([item1.json, item2.json])
        
        let result =
        try FeedItemsMapper
            .map(json,
                 from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL) ->
    (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL)
        // To avoid typecasting json to as [String : Any] we can use reduce()
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (item, json )
    }
}
