//
//  UIButton+TestHelpers.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 10/7/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
