//
//  FeedUIComposer.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/8/23.
//

import EssentialFeed_2023

// Composer Rules
// - Composers should only be used in the Composition Root
// - Only Composers can use other Composers
public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedViewController, loader: imageLoader)
        return feedViewController
    }
    
    // When composing types the adapter pattern helps to connect unmatching APIs
    // In this case [FeedImage] -> Adapts -> [FeedImageCellController]
    // The Adapter pattern enables components with incompatible interfaces to work together seamlessly.
    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
            return { [weak controller] feed in
                controller?.tableModel = feed.map { model in
                    FeedImageCellController(model: model, imageLoader: loader)
                }
            }
        }
}
