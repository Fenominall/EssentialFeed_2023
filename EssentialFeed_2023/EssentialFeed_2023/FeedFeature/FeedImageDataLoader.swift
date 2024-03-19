//
//  FeedImageDataLoader.swift
//  EssentialFeed_2023iOS
//
//  Created by Fenominall on 10/7/23.
//

import Foundation

public protocol FeedImageDataLoader {    
    func loadImageData(from url: URL) throws -> Data
}
