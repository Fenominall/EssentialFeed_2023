//
//  FeedLoader.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/21/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
