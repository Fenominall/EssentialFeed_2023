//
//  ImageCommentsEndPoint.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 15.02.2024.
//

import Foundation

public enum ImageCommentsEndPoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("v1/image/\(id)/comments")
        }
    }
}
