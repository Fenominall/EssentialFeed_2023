//
//  HTTPClient.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/27/23.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    ///  The completion handler can be invoiked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
