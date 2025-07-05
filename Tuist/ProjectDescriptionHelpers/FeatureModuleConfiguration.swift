//
//  FeatureModuleConfiguration.swift
//  ProjectDescriptionHelpers
//
//  Created by MacPro on 14/06/25.
//

import Foundation
import ProjectDescription

public struct FeatureModuleConfiguration: Sendable {
    let name: String
    let bundleId: String
    let organizationName: String
    
    // Feature-specific target names
    var domainName: String { "\(name)Domain" }
    var dataName: String { "\(name)Data" }
    var testingName: String { "\(name)Testing" }
    
    // Separate test targets for each layer
    var presentationTestsName: String { "\(name)Tests" }
    var domainTestsName: String { "\(name)DomainTests" }
    var dataTestsName: String { "\(name)DataTests" }
    
    // Bundle IDs for each target
    var moduleBundleId: String { "\(bundleId).\(name)" }
    var domainBundleId: String { "\(bundleId).\(domainName)" }
    var dataBundleId: String { "\(bundleId).\(dataName)" }
    var testingBundleId: String { "\(bundleId).\(testingName)" }
    var presentationTestsBundleId: String { "\(bundleId).\(presentationTestsName)" }
    var domainTestsBundleId: String { "\(bundleId).\(domainTestsName)" }
    var dataTestsBundleId: String { "\(bundleId).\(dataTestsName)" }
    
    public init(name: String,
         bundleId: String = "br.com.tvshowsapp",
         organizationName: String = "Cesar Lima Consulting") {
        self.name = name
        self.bundleId = bundleId
        self.organizationName = organizationName
    }
}

// MARK: - Feature Project Factory
extension Project {
    /// Creates a feature module project with Clean Architecture layers and separate test targets
    public static func featureModule(
        configuration: FeatureModuleConfiguration,
        presentationDependencies: [TargetDependency] = [],
        domainDependencies: [TargetDependency] = [],
        dataDependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = [],
        additionalSettings: SettingsDictionary = [:]
    ) -> Project {
        let targets = [
            // Presentation target (main feature target)
            Target.framework(
                name: configuration.name,
                bundleId: configuration.moduleBundleId,
                dependencies: [.target(name: configuration.domainName)] + presentationDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Domain target (business logic)
            Target.framework(
                name: configuration.domainName,
                bundleId: configuration.domainBundleId,
                dependencies: domainDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Data target (data access)
            Target.framework(
                name: configuration.dataName,
                bundleId: configuration.dataBundleId,
                dependencies: [.target(name: configuration.domainName)] + dataDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Testing target (test doubles)
            Target.testing(
                name: configuration.testingName,
                bundleId: configuration.testingBundleId,
                interfaceTarget: configuration.domainName,
                additionalSettings: additionalSettings
            ),
            
            // Presentation Tests target
            Target.unitTests(
                name: configuration.presentationTestsName,
                bundleId: configuration.presentationTestsBundleId,
                implementationTarget: configuration.name,
                testingTarget: configuration.testingName,
                dependencies: [
                    .target(name: configuration.domainName)
                ] + testDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Domain Tests target
            Target.unitTests(
                name: configuration.domainTestsName,
                bundleId: configuration.domainTestsBundleId,
                implementationTarget: configuration.domainName,
                testingTarget: configuration.testingName,
                dependencies: testDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Data Tests target
            Target.unitTests(
                name: configuration.dataTestsName,
                bundleId: configuration.dataTestsBundleId,
                implementationTarget: configuration.dataName,
                testingTarget: configuration.testingName,
                dependencies: [
                    .target(name: configuration.domainName)
                ] + testDependencies,
                additionalSettings: additionalSettings
            )
        ]
        
        let schemes = [
            // Main scheme that runs all tests
            Scheme.feature(
                name: configuration.name,
                implementationTarget: configuration.name,
                testTargets: [
                    configuration.presentationTestsName,
                    configuration.domainTestsName,
                    configuration.dataTestsName
                ]
            )
        ]
        
        return Project(
            name: configuration.name,
            organizationName: configuration.organizationName,
            options: .standardOptions,
            packages: [],
            settings: .settings(base: .commonBuildSettings),
            targets: targets,
            schemes: schemes
        )
    }
} 