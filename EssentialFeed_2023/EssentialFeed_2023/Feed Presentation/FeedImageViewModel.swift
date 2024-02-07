//
//  FeedImageViewModel.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 11/25/23.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
