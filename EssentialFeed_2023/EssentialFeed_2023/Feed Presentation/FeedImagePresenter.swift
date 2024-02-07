//
//  FeedImagePresenter.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 11/25/23.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
