//
//  FeedCacheTestHelpers.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/8/23.
//

import Foundation

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    // computed property because extension cannot have stored properties
    private var feedCacheMaxAgeInDays: Int { return 7 }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
