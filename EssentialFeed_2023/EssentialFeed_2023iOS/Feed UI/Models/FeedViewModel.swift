//
//  FeedViewModel.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/18/23.
//

import EssentialFeed_2023

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // Returns a reference of the FeedViewModel
    var onChange: ((FeedViewModel) -> Void)?
    // The way to send the result outside of the clise via using a closure
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}

