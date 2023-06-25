//
//  FeedCachePolicy.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/10/23.
//

import Foundation

// Business rules can be extracted to it`s own model and be reused across applications later
final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAge: Int {
        7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar
            .date(byAdding: .day, value: maxCacheAge, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

public final class TestCIScheme {}
