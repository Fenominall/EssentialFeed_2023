//
//  UIView+TestHelpers.swift .swift
//  EssentialAppTests
//
//  Created by Владислав Тодоров on 16.01.2024.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
