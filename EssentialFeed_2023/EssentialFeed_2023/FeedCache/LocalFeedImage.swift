//
//  LocalFeedImage.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/6/23.
//

import Foundation

import Foundation

// Add 'LocalFeedImage' data transfer representation to decouple storage frameworks from 'FeedImage' data models
// Data Transfer Object to remove strong coupling between modules
public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID,
                description: String? = nil,
                location: String? = nil,
                url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = url
    }
}
