//
//  FeedImageDataStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 30.12.2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

