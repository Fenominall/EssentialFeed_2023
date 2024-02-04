//
//  SharedLocalizationTests.swift
//  EssentialFeed_2023Tests
//
//  Created by Владислав Тодоров on 03.02.2024.
//

import XCTest
import EssentialFeed_2023

class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
}
