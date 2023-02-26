//
//  FeedItemsMapper.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/26/23.
//

import Foundation

// Lesson
// 1. Being careful  with the Decodable design because it can couple modules
// 2. Cassisit approch by keeping to add test and refcatoring
final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private struct RemoteFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return .init(
                id: id,
                description: description,
                location: location,
                imageURL: image)
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.isOK else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
