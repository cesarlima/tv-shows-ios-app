//
//  HTTPBody.swift
//  NetworkingInterface
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

public struct HTTPBody {
    public let defaultHeaders: [String: String]
    public let encode: () throws -> Data
    
    public static func empty() -> HTTPBody {
        return HTTPBody(defaultHeaders: [:], encode: { Data() })
    }
}
