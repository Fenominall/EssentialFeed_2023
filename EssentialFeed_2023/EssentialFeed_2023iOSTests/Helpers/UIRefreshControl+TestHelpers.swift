//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 10/7/23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

