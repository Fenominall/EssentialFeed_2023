//
//  FeedViewModel.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/18/23.
//

import EssentialFeed_2023

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // Closure observers for states
    var onLoadingStateChange: Observer<Bool>?
    // The way to send the result outside of the class via using a closure
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}

