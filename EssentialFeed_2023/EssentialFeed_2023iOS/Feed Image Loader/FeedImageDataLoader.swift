//
//  FeedImageDataLoader.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/7/23.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
