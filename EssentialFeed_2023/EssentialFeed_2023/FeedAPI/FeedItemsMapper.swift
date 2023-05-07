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
internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }
    
    // using gualed let self = self else { return } is tricky because if an isntance has been deallocated then the code bellow will not be executed.
    // With the static method even if RemoteFeedLoader is deallocated, then FeedItemsMapper may still be invoked and calling a completion block
    internal static func map(
        _ data: Data,
        from response: HTTPURLResponse) throws -> [RemoteFeedImage] {
            guard response.isOK,
                  let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteFeedLoader.Error.invalidData
                
            }
            return root.items
        }
}

