//
//  HTTPClient.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/27/23.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    ///  The completion handler can be invoiked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

