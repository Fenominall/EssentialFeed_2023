//
//  FeedLocalizationTests.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 11/20/23.
//

import XCTest
import EssentialFeed_2023

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
       
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
