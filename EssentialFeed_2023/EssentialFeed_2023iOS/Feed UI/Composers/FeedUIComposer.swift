//
//  FeedUIComposer.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/8/23.
//

import EssentialFeed_2023
import UIKit

// Composer Rules
// - Composers should only be used in the Composition Root
// - Only Composers can use other Composers
public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        // Objects should not create their dependencies, it should be done in the composer
        // This is the right way
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedViewController, loader: imageLoader)
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
                    FeedImageCellController(
                        viewModel:
                            FeedImageViewModel(
                                model: model,
                                imageLoader: loader,
                                imageTransformer: UIImage.init))
                }
            }
        }
}
