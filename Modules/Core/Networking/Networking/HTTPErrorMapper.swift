//
//  HTTPErrorMapper.swift
//  NetworkingInterface
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation
import NetworkingInterface

struct HTTPErrorMapper {
    static func map(_ error: Error, response: URLResponse?) -> HTTPClientError {
        if let urlError = error as? URLError {
            return mapURLError(urlError)
        }
        
        return .networkError(underlying: error)
    }
    
    private static func mapURLError(_ error: URLError) -> HTTPClientError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        default:
            return .networkError(underlying: error)
        }
    }
    
    static func mapHTTPResponse(_ response: HTTPURLResponse) -> HTTPClientError {
        switch response.statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .internalServerError
        case 400...499:
            return .clientError(statusCode: response.statusCode)
        default:
            return .unknown
        }
    }
}
