//
//  HTTPClient.swift
//  Networking
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func perform(_ request: HTTPRequest) async throws -> HTTPResult
}
