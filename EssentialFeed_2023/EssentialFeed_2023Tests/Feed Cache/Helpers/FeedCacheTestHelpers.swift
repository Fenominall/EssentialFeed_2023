//
//  FeedCacheTestHelpers.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/8/23.
//


import Foundation
import EssentialFeed_2023

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(),
              description: "descreption",
              location: "location",
              url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localFeedImages = feed.map {
        LocalFeedImage(
            id: $0.id,
            description:
                $0.description,
            location: $0.location,
            url: $0.url) }
    return (feed, localFeedImages)
}

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
}


extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
