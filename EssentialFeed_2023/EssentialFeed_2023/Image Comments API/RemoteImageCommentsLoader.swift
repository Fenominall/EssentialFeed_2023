//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed_2023
//
//  Created by Владислав Тодоров on 28.01.2024.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
