//
//  FeedUIComposer.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/8/23.
//

import UIKit
import Combine
import EssentialFeed_2023
import EssentialFeed_2023iOS

// MARK: - FeedUIComposer
// Composer Rules
// - Composers should only be used in the Composition Root
// - Only Composers can use other Composers
public final class FeedUIComposer {
    private init() {}
    
    // Passing a function taht can create Feedloader publishers
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher,
                                        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        // Objects should not create their dependencies, it should be done in the composer
        // This is the right way
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title
        return feedViewController
    }
}
