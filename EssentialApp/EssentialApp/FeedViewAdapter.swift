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
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMoreDataPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    init(controller: ListViewController,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
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
            
            return CellController(id: model ,view)
        }
        
        // if do not have to load more, display the current feed
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMoreDataPresentationAdapter(loader: loadMorePublisher)
        
        let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: self,
            loadingView: WeakRefVirtualProxy(loadMoreController),
            errorView: WeakRefVirtualProxy(loadMoreController))
        
        let loadMoreSection = [CellController(id: UUID(), loadMoreController)]
        
        controller?.display(feed, loadMoreSection)
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
