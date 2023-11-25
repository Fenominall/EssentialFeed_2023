//
//  FeedImageViewModel.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 11/25/23.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
