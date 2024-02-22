//
//  FeedViewController.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 7/16/23.
//

import UIKit
import EssentialFeed_2023

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    private(set) public var errorView = ErrorView()
    
    private var loadingControllers = [IndexPath: CellController]()
    
    // # Step 1
    // control the state to reload automatically what cahnge, using Int for section and the models for data source
    // The model needs to be hashable
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, indexPath, controller) in
            return controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    public var onRefresh: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureTraitCollectionObservers()
        refresh()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        // # Step 2 - make UITableViewController as UITableViewDiffableDataSource
        tableView.dataSource = dataSource
        tableView.tableHeaderView = errorView.makeContainer()
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderFit()
            self?.tableView.endUpdates()
        }
    }
    
    private func configureTraitCollectionObservers() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges(
                [UITraitPreferredContentSizeCategory.self]
            ) { (self: Self, previous: UITraitCollection) in
                self.tableView.reloadData()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Every time the method is called, the header view will be resized
        tableView.sizeTableHeaderFit()
    }
    
    @objc private func refresh() {
        onRefresh?()
    }
    
    // # Step 3
    // every time new controllers arrive
    // Using ... dots to support multiple sections
    public func display(_ sections: [CellController]...) {
        // a new empty snapshot created
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        // new controllers appended
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }
        // data source will ceck what change using the hashable implementation and only updates what is necessary
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let delegate = cellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsPrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dsPrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsPrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dsPrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    // MARK: - Helpers
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}
