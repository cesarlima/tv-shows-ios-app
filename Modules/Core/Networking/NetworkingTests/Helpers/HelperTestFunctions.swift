//
//  HelperTestFunctions.swift
//  NetworkingTests
//
//  Created by MacPro on 28/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

func makeError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func makeValidData() -> Data {
    return Data("{ \"id\": 1 }".utf8)
}

func makeHTTPURLResponse(statusCode: Int = 200,
                         url: URL = URL(string: "https://a-url.com/path")!) -> HTTPURLResponse {
    return HTTPURLResponse(url: url,
                           statusCode: statusCode,
                           httpVersion: nil,
                           headerFields: nil)!
}
