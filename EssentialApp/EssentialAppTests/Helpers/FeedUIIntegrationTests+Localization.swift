//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeed_2023iOSTests
//
//  Created by Fenominall on 11/20/23.
//

import Foundation
import XCTest
import EssentialFeed_2023

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
}
