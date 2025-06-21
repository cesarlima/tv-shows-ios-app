//
//  Scheme+Extension.swift
//  Packages
//
//  Created by MacPro on 19/06/25.
//

import ProjectDescription

extension Scheme {
    /// Creates a standard scheme for a module
    static func module(
        name: String,
        implementationTarget: String,
        testsTarget: String
    ) -> Scheme {
        return .scheme(
            name: name,
            buildAction: .buildAction(targets: [.target(implementationTarget)]),
            testAction: .targets([.testableTarget(target: .target(testsTarget))]),
            runAction: .runAction(executable: .target(implementationTarget))
        )
    }
}
