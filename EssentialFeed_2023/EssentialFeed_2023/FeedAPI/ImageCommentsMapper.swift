//
//  ImageCommentsMapper.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 28.01.2024.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedImage]
    }
    
    static func map(
        _ data: Data,
        from response: HTTPURLResponse) throws -> [RemoteFeedImage] {
            guard isOK(response),
                  let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteImageCommentsLoader.Error.invalidData
                
            }
            return root.items
        }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
