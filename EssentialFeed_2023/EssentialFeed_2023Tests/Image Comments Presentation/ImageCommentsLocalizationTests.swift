//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Владислав Тодоров on 07.02.2024.
//

import XCTest
import EssentialFeed_2023

class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
       
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
