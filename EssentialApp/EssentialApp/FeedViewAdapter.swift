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
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
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
        
        let loadMore = LoadMoreCellController {
            viewModel.loadMore?({ _ in })
        }
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
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
