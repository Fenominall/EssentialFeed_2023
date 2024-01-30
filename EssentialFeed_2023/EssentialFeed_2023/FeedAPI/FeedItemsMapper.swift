//
//  FeedItemsMapper.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/27/23.
//

import Foundation

// Lesson
// 1. Being careful  with the Decodable design because it can couple modules
// 2. Classisit approch by keeping to add test and refcatoring
public final class FeedItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteFeedImage]
        
        // For decoding objects a safer way to use models that represent json
        private struct RemoteFeedImage: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map {
                FeedImage(
                    id: $0.id,
                    description: $0.description,
                    location: $0.location,
                    url: $0.image)
            }
        }
    }
    
    public static func map(
        _ data: Data,
        from response: HTTPURLResponse) throws -> [FeedImage] {
            guard response.isOK,
                  let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteFeedLoader.Error.invalidData
                
            }
            return root.images
        }
}
