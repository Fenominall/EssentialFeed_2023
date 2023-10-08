//
//  FeedRefreshViewController.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/8/23.
//

import UIKit
import EssentialFeed_2023

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader

    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    // The way to send the result outside of the clise via using a closure
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
