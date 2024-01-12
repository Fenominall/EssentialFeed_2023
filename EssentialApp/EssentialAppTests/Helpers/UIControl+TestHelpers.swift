//
//  UIControl+TestHelpers.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 10/7/23.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
