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
        .init(tableView: tableView) { tableView, indexPath, controller in
            print("\(indexPath)")
            return controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    public var onRefresh: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // # Step 2 - make UITableViewController as UITableViewDiffableDataSource
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
            
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderFit()
            self?.tableView.endUpdates()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Every time the method is called, the header view will be resized
        tableView.sizeTableHeaderFit()
    }
        
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    // # Step 3
    // every time new controllers arrive
    public func display(_ cellControllers: [CellController]) {
        // a new empty snapshot created
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        // new controllers appended
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        // data source will ceck what change using the hashable implementation and only updates what is necessary
        dataSource.apply(snapshot)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellControll(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsPrefetching = cellControll(at: indexPath)?.dataSourcePrefetching
            dsPrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsPrefetching = cellControll(at: indexPath)?.dataSourcePrefetching
            dsPrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    // MARK: - Helpers
    private func cellControll(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}
