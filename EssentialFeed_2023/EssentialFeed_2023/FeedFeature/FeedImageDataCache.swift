//
//  FeedImageDataCache.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 10.01.2024.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
