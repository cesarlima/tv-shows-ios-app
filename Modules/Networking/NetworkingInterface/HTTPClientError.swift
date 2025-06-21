//
//  HTTPClientError.swift
//  NetworkingInterface
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

public enum HTTPClientError: LocalizedError, Equatable {
    case invalidURL
    case networkError(underlying: Error)
    case serverError(statusCode: Int)
    case clientError(statusCode: Int)
    case timeout
    case noConnection
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .clientError(let statusCode):
            return "Client error with status code: \(statusCode)"
        case .timeout:
            return "Request timed out"
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .internalServerError:
            return "Internal server error"
        case .unknown:
            return "Unknown error occurred"
        }
    }
    
    public static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription
    }
}
