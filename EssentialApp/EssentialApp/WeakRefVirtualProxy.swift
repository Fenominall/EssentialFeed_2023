//
//  WeakRefVirtualProxy.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/21/23.
//

import UIKit
import EssentialFeed_2023


// MARK: - WeakRefVirtualProxy
// Memory management is a composition detail that should not be part of MVP components.
// This class helps to eleminate memory management in Presenters
final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
    func display(_ model: UIImage) {
        object?.display(model)
    }
}

