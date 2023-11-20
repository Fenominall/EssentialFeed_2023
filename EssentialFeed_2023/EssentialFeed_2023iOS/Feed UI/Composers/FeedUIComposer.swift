//
//  FeedUIComposer.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/8/23.
//

import EssentialFeed_2023
import UIKit

// MARK: - FeedUIComposer
// Composer Rules
// - Composers should only be used in the Composition Root
// - Only Composers can use other Composers
public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        // Objects should not create their dependencies, it should be done in the composer
        // This is the right way
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.refreshController = refreshController
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(refreshController))
        return feedViewController
    }
}

// MARK: - WeakRefVirtualProxy
// Memory management is a composition detail that should not be part of MVP components.
// This class helps to eleminate memory management in Presenters
private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
    
    
}

// MARK: - FeedViewAdapter
private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
