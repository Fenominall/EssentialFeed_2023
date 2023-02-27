//
//  FeedItemsMapper.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/27/23.
//

import Foundation


// Lesson
// 1. Being careful  with the Decodable design because it can couple modules
// 2. Cassisit approch by keeping to add test and refcatoring
internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        // Eleminating mapping logic from the map function
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
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
    
    internal static func map(
        _ data: Data,
        from response: HTTPURLResponse) -> RemoteFeedLoader.Results {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else
            { return .failure(.invalidData) }
            
            return .success(root.feed)
    }
}

