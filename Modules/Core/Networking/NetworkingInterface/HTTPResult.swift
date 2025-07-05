//
//  HTTPResult.swift
//  NetworkingInterface
//
//  Created by MacPro on 21/06/25.
//  Copyright © 2025 Cesar Lima Consulting. All rights reserved.
//

import Foundation

public struct HTTPResult {
    public let data: Data
    public let response: HTTPURLResponse
    
    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
}
