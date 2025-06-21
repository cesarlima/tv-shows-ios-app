//
//  Target+Extension.swift
//  Packages
//
//  Created by MacPro on 19/06/25.
//

import ProjectDescription

extension Target {
    /// Creates a framework target with standard configuration
    static func defaultTarget(
        name: String,
        bundleId: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = nil,
        product: Product,
        infoPlist: InfoPlist? = .default,
        dependencies: [TargetDependency] = [],
        additionalSettings: SettingsDictionary = [:]
    ) -> Target {
        return .target(
            name: name,
            destinations: [.mac, .iPhone],
            product: product,
            bundleId: bundleId,
            deploymentTargets: .multiplatform(macOS: "14.2"),
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: .settings(base: additionalSettings)
        )
    }
    
    /// Creates a framework target with standard configuration
    static func framework(
        name: String,
        bundleId: String,
        sources: SourceFilesList? = nil,
        dependencies: [TargetDependency] = [],
        additionalSettings: SettingsDictionary = [:]
    ) -> Target {
        let frameworkSources = sources ?? ["\(name)/**"]
        return .defaultTarget(
            name: name,
            bundleId: bundleId,
            sources: frameworkSources,
            product: .framework,
            dependencies: dependencies,
            additionalSettings: additionalSettings
        )
    }
    
    /// Creates an interface framework target
    static func interface(
        name: String,
        bundleId: String,
        additionalSettings: SettingsDictionary = [:],
        dependencies: [TargetDependency] = []
    ) -> Target {
        return .framework(
            name: name,
            bundleId: bundleId,
            dependencies: dependencies,
            additionalSettings: additionalSettings
        )
    }
    
    /// Creates a testing framework target (for test doubles)
    static func testing(
        name: String,
        bundleId: String,
        interfaceTarget: String,
        additionalSettings: SettingsDictionary = [:]
    ) -> Target {
        return .framework(
            name: name,
            bundleId: bundleId,
            dependencies: [.target(name: interfaceTarget)],
            additionalSettings: additionalSettings
        )
    }
    
    /// Creates a unit tests target
    static func unitTests(
        name: String,
        bundleId: String,
        implementationTarget: String,
        testingTarget: String,
        additionalSettings: SettingsDictionary = [:],
        dependencies: [TargetDependency] = []
    ) -> Target {
        let testDependencies = dependencies + [
            .target(name: implementationTarget),
            .target(name: testingTarget)
        ]
        
        return .defaultTarget(
            name: name,
            bundleId: bundleId,
            sources: ["\(name)/**"],
            product: .unitTests,
            dependencies: testDependencies,
            additionalSettings: additionalSettings
        )
    }
}
