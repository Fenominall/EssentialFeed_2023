//
//  FeedCache.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 07.01.2024.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>

    func save(_ feed: [FeedImage],
                     completion: @escaping (SaveResult) -> Void)
}
