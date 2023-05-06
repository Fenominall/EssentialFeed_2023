//
//  LocalFeedItem.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/6/23.
//

import Foundation

import Foundation

// Add 'LocalFeedItem' data transfer representation to decouple storage frameworks from 'FeedItem' data models
// Data Transfer Object to remove strong coupling between modules
public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID,
                description: String? = nil,
                location: String? = nil,
                imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
