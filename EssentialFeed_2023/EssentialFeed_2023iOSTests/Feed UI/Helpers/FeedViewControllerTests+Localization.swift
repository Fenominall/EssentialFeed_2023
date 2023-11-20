//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 11/20/23.
//

import Foundation
import EssentialFeed_2023iOS
import XCTest

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}