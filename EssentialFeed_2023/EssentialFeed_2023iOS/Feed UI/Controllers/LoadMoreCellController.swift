//
//  LoadMoreCellController.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 2/18/24.
//

import UIKit
import EssentialFeed_2023

public final class LoadMoreCellController: NSObject, UITableViewDataSource {
    private let cell = LoadMoreCell()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: EssentialFeed_2023.ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
    
    public func display(_ viewModel: EssentialFeed_2023.ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}
