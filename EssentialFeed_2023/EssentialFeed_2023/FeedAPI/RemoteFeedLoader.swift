//
//  RemoteFeedLoader.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/25/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public typealias Results = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Results) -> Void) {
        client.get(from: url) { [weak self] result in
            // Guarantee we do not deliver a result (invoke the completion closure) after the 'RemoteFeedLoader' instance has been deallocated
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Results {
        do {
            let itmes = try FeedItemsMapper.map(data, from: response)
            return .success(itmes.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map {
            FeedItem(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                imageURL: $0.image)
        }
    }
}

