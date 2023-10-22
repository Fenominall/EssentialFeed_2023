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
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            // using gualed let self = self else { return } is tricky because if an isntance has been deallocated then the code bellow will not be executed.
            // With the static method even if RemoteFeedLoader is deallocated, then FeedItemsMapper may still be invoked and calling a completion block
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
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let itmes = try FeedItemsMapper.map(data, from: response)
            return .success(itmes.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.image)
        }
    }
}

