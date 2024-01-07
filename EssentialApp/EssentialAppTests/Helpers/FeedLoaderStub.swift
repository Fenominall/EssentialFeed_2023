//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Fenominall on 07.01.2024.
//

import EssentialFeed_2023

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
