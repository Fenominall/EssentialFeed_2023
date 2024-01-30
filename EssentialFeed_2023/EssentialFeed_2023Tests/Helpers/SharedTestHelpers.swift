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


extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(
            url: anyURL(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}

//Function to group items into a payloud contract
func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}
