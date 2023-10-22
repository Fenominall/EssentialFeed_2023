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
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedPresenter.loadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        return feedViewController
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [EssentialFeed_2023.FeedImage]) {
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
