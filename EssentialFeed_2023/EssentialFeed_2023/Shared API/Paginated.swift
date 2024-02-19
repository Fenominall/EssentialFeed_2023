//
//  Paginated.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 19.02.2024.
//

import Foundation

//[*] Layout
//[] Infinite Scroll Expirience
  // [] Trigger "Load more" action on scroll to bottom
    // [] Only if there are more items to load
    // [] Only if not already loading
  // [] Show loading indicator while loading
  // [] Show error message on failure
    // [] Tap on error to retry
public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
    
    public let items: [Item]
    public let loadMore: ((@escaping LoadMoreCompletion) ->Void)?
    
    public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion ) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
