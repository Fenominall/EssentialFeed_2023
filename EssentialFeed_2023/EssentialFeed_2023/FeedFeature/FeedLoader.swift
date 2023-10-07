//
//  FeedLoader.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/21/23.
//

import Foundation


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}


