//
//  FeedImageDataMapper.swift
//  EssentialApp
//
//  Created by Владислав Тодоров on 01.02.2024.
//

import Foundation

public final class FeedImageDataMapper {
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(
        _ data: Data,
        from response: HTTPURLResponse) throws -> Data {
            guard response.isOK, !data.isEmpty else {
                throw NSError(domain: "0", code: 1)
                }
            return Data()
        }
}
