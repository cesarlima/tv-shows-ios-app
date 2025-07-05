//
//  HTTPRequest.swift
//  NetworkingInterface
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

public protocol HTTPRequest {
    var host: String { get }
    var path: String { get }
    var scheme: HTTPScheme { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: HTTPBody { get }
    var queryParams: [String: String]? { get }
}

extension HTTPRequest {
    public var scheme: HTTPScheme {
        return .https
    }

    public var body: HTTPBody {
        return .empty()
    }
    
    public var queryParams: [String: String]? {
        return nil
    }
    
    public func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.queryItems = queryParamsToQueryItems()
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try body.encode()
        return request
    }
    
    private func queryParamsToQueryItems() -> [URLQueryItem]? {
        return queryParams?.map { key, value in
            URLQueryItem(name: key, value: value)
        }
    }
}
