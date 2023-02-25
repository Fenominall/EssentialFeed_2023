//
//  FeedItem.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/21/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let descreption: String?
    let location: String?
    let imageURL: URL
}
