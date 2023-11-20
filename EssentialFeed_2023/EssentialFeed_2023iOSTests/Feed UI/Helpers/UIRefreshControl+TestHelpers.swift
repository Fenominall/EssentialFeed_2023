//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 10/7/23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
