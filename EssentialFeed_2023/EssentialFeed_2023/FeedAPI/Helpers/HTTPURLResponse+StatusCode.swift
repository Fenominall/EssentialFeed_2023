//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 2/26/23.
// Project

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }    
}
