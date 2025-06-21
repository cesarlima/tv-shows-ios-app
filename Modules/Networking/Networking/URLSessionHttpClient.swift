//
//  URLSessionHttpClient.swift
//  Networking
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation
import NetworkingInterface

final class URLSessionHttpClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func perform(_ request: HTTPRequest) async throws -> HTTPResult {
        do {
            let (data, response) = try await session.data(for: request.asURLRequest())
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw HTTPErrorMapper.mapHTTPResponse(httpResponse)
            }
            
            return HTTPResult(data: data, response: httpResponse)
        } catch let error as HTTPClientError {
            throw error
        } catch {
            throw HTTPErrorMapper.map(error, response: nil)
        }
    }
}
