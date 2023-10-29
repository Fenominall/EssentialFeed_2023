//
//  FeedImageViewModel.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/18/23.
//

import EssentialFeed_2023
import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
