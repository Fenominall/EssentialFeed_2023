//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Владислав Тодоров on 10.01.2024.
//

import Foundation
import EssentialFeed_2023

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result
                .map({ data in
                    self?.cache.saveIngoringResult(data, for: url)
                    return data
                })
            )
        }
    }
}

private extension FeedImageDataCache {
    func saveIngoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

