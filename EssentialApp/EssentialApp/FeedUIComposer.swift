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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    // Passing a function taht can create Feedloader publishers
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void)
    -> ListViewController {
        // Objects should not create their dependencies, it should be done in the composer
        // This is the right way
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        
        let feedController = ListViewController.makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader,
                selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))
        return feedController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! ListViewController
        feedViewController.title = title
        return feedViewController
    }
}
