//
//  WeakRefVirtualProxy.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/21/23.
//

import EssentialFeed_2023
import UIKit

// MARK: - WeakRefVirtualProxy
// Memory management is a composition detail that should not be part of MVP components.
// This class helps to eleminate memory management in Presenters
final class WeakRefVirtualProxy<T: AnyObject> {
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
