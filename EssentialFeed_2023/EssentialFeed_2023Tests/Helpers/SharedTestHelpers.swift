//
//  SharedTestHelpers.swift
//  EssentialFeed_2023Tests
//
//  Created by Fenominall on 5/9/23.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https:any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error",
                   code: 1)
}

func anyData() -> Data {
    return Data("invalid json".utf8)
}
