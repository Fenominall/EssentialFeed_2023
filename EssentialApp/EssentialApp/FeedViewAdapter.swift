//
//  FeedViewAdapter.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/21/23.
//

import UIKit
import EssentialFeed_2023
import EssentialFeed_2023iOS

// MARK: - FeedViewAdapter
final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    private let currentFeed: [FeedImage: CellController]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMoreDataPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    init(currentFeed: [FeedImage: CellController] = [:],
         controller: ListViewController,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = controller else { return }
        var currentFeed = self.currentFeed
        let feed: [CellController] = viewModel.items.map { model in
            if let contoller = currentFeed[model] {
                return contoller
            }
            // Loader does not take parameters the function was applied partially
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter, 
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: mapDataIntoImage)
            
            let controller = CellController(id: model ,view)
            currentFeed[model] = controller
            return controller
        }
        
        // if do not have to load more, display the current feed
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMoreDataPresentationAdapter(loader: loadMorePublisher)
        
        let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                currentFeed: currentFeed,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection),
            loadingView: WeakRefVirtualProxy(loadMoreController),
            errorView: WeakRefVirtualProxy(loadMoreController))
        
        let loadMoreSection = [CellController(id: UUID(), loadMoreController)]
        
        controller.display(feed, loadMoreSection)
    }
    // MARK: - Helpers
    private func mapDataIntoImage(_ data: Data) throws -> UIImage {
            guard let image = UIImage(data: data) else {
                throw InvalidImageDataError()
            }
            return image
    }
}

private class InvalidImageDataError: Error {}
