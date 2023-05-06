//
//  RemoteFeedItem.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/6/23.
//

import Foundation

// For decoding objects a safer way to use models that represent json
internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
