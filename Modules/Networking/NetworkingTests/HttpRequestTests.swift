//
//  HttpRequestTests.swift
//  NetworkingTests
//
//  Created by MacPro on 23/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import XCTest
import NetworkingInterface

final class HttpRequestTests: XCTestCase {
    func test_asURLRequest_createURLRequestWithCorrectValues() async {
        let sut = Request()
        
        do {
            let result = try sut.asURLRequest()
            let expectedURLRequest = try makeURLRequest(sut)
            
            XCTAssertEqual(result.url, expectedURLRequest.url)
            XCTAssertEqual(result.httpMethod, expectedURLRequest.httpMethod)
            XCTAssertEqual(result.httpBody, expectedURLRequest.httpBody)
            
            for (key, value) in expectedURLRequest.allHTTPHeaderFields ?? [:] {
                XCTAssertEqual(result.allHTTPHeaderFields?[key], value,
                               "Expected header \(key): \(value), got \(String(describing: result.allHTTPHeaderFields?[key]))")
            }
            
        } catch {
            XCTFail("Expected success, got \(error)")
        }
    }

    private func makeURLRequest(_ request: HTTPRequest) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = request.scheme.rawValue
        components.host = request.host
        components.path = request.path
        components.queryItems = request.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else {
            throw NSError(domain: "Could not create URL", code: 0, userInfo: nil)
        }
        var result = URLRequest(url: url)
        result.httpMethod = request.method.rawValue
        result.allHTTPHeaderFields = request.headers
        result.httpBody = try request.body.encode()
        
        return result
    }
}

private struct Request: HTTPRequest {
    var host: String = "localhost"
    var path: String = "/any-path"
    var method: HTTPMethod = .get
    var headers: [String : String] = ["any-header": "any-header-value"]
    var body: HTTPBody = .empty()
    var queryParams: [String : String]? = ["any-param": "any-param-value"]
}
