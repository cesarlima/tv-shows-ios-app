//
//  RequestMock.swift
//  NetworkingTesting
//
//  Created by MacPro on 28/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation
import NetworkingInterface

public struct RequestMock: HTTPRequest {
    public var scheme: HTTPScheme
    public var host: String
    public var path: String
    public var method: HTTPMethod
    public var headers: [String: String]
    public var body: HTTPBody
    public var url: URL {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        return components.url!
    }
    
    public init(host: String = "a-url.com",
                path: String = "/path",
                scheme: HTTPScheme = .https,
                method: HTTPMethod = .get,
                headers: [String : String] = [:],
                body: HTTPBody = .empty()) {
        self.host = host
        self.path = path
        self.scheme = scheme
        self.method = method
        self.headers = headers
        self.body = body
    }
}
