//
//  FeedPresenter.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 11/23/23.
//

import Foundation

public final class FeedPresenter {
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
}
