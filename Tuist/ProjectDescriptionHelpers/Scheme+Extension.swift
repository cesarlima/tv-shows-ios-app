//
//  Scheme+Extension.swift
//  Packages
//
//  Created by MacPro on 19/06/25.
//

import ProjectDescription

extension Scheme {
      /// Creates a scheme for a module with test targets
    static func module(
        name: String,
        implementationTarget: String,
        testTargets: [String]
    ) -> Scheme {
        let testableTargets = testTargets.map { TestableTarget.testableTarget(target: TargetReference.target($0)) }
        return .scheme(
            name: name,
            buildAction: .buildAction(targets: [TargetReference.target(implementationTarget)]),
            testAction: .targets(testableTargets),
            runAction: .runAction(executable: TargetReference.target(implementationTarget))
        )
    }
    
    /// Convenience function for a module with a single test target
    static func module(
        name: String,
        implementationTarget: String,
        testsTarget: String
    ) -> Scheme {
        return module(
            name: name,
            implementationTarget: implementationTarget,
            testTargets: [testsTarget]
        )
    }
}
