//
//  feature-module.swift
//  Templates
//
//  Created by MacPro on 14/06/25.
//

import ProjectDescription

fileprivate let featureName: Template.Attribute = .required("name")

let template = Template(
    description: "A template for feature modules following Clean Architecture with TMA and separate test targets",
    attributes: [
        featureName,
        .optional("platform", default: "ios"),
    ],
    items: [
        // Project configuration
        .string(
            path: "Features/\(featureName)/Project.swift",
            contents: """
            import ProjectDescription
            import ProjectDescriptionHelpers

            let configuration = FeatureModuleConfiguration(
                name: "\(featureName)"
            )

            let project = Project.featureModule(
                configuration: configuration,
                presentationDependencies: [
                    // Add presentation dependencies here (e.g., UI frameworks)
                ],
                domainDependencies: [
                    // Add domain dependencies here (e.g., shared domain modules)
                ],
                dataDependencies: [
                    // Add data dependencies here (e.g., networking, persistence)
                ],
                testDependencies: [
                    // Add test dependencies here
                ]
            )
            """
        ),
        
        // Domain Layer
        .file(
            path: "Features/\(featureName)/\(featureName)Domain/\(featureName)Domain.swift",
            templatePath: "Domain/FeatureDomain.stencil"
        ),
        
        // Data Layer
        .file(
            path: "Features/\(featureName)/\(featureName)Data/\(featureName)Repository.swift",
            templatePath: "Data/FeatureRepository.stencil"
        ),
        
        // Presentation Layer
        .file(
            path: "Features/\(featureName)/\(featureName)/\(featureName)ViewModel.swift",
            templatePath: "Presentation/FeatureViewModel.stencil"
        ),
        
        // Testing Layer
        .file(
            path: "Features/\(featureName)/\(featureName)Testing/\(featureName)Testing.swift",
            templatePath: "Testing/FeatureTesting.stencil"
        ),
        
        // Test files
        .file(
            path: "Features/\(featureName)/\(featureName)DomainTests/\(featureName)DomainTests.swift",
            templatePath: "Tests/DomainTests.stencil"
        ),
        .file(
            path: "Features/\(featureName)/\(featureName)DataTests/\(featureName)DataTests.swift",
            templatePath: "Tests/DataTests.stencil"
        ),
        .file(
            path: "Features/\(featureName)/\(featureName)Tests/\(featureName)Tests.swift",
            templatePath: "Tests/PresentationTests.stencil"
        )
    ]
) 