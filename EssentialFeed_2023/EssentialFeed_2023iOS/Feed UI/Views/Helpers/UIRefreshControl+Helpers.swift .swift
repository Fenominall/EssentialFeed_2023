//
//  UIRefreshControl+Helpers.swift .swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 11/22/23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        return isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
