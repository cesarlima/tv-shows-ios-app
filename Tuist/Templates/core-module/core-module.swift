//
//  CoreModule.swift
//  Config
//
//  Created by MacPro on 14/06/25.
//

import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")
let bundleIdAttribute: Template.Attribute = .required("bundleId")

let template = Template(
    description: "A template for core modules following TMA architecture",
    attributes: [
        nameAttribute,
        bundleIdAttribute,
        .optional("platform", default: "ios"),
    ],
    items: [
        .string(
            path: "Modules/\(nameAttribute)/Project.swift",
            contents: """
            import ProjectDescription

            let project = Project(
                name: "\(nameAttribute)",
                organizationName: "TVShowsApp",
                options: .options(
                    automaticSchemesOptions: .disabled,
                    disableBundleAccessors: false
                ),
                packages: [],
                settings: .settings(
                    base: [
                        "SWIFT_VERSION": "5.0",
                        "IPHONEOS_DEPLOYMENT_TARGET": "15.0"
                    ]
                ),
                targets: [
                    // Source target
                    .target(name: "\(nameAttribute)",
                            destinations: [.mac, .iPhone],
                            product: .framework,
                            bundleId: "\(bundleIdAttribute)",
                            deploymentTargets: .multiplatform(macOS: "14.2"),
                            infoPlist: .default,
                            sources: ["Sources/**"],
                            dependencies: [.target(name: "\(nameAttribute)Interface")]),
                    
                    // Interface target
                    .target(name: "\(nameAttribute)Interface",
                            destinations: [.mac, .iPhone],
                            product: .framework,
                            bundleId: "\(bundleIdAttribute).interface",
                            deploymentTargets: .multiplatform(macOS: "14.2"),
                            infoPlist: .default,
                            sources: ["Interface/**"]
                           ),
                    
                    // Tests target
                    .target(name: "\(nameAttribute)Tests",
                            destinations: [.mac, .iPhone],
                            product: .unitTests,
                            bundleId: "\(bundleIdAttribute).tests",
                            deploymentTargets: .multiplatform(macOS: "14.2"),
                            infoPlist: .default,
                            sources: ["Tests/**"],
                            dependencies: [
                                .target(name: "\(nameAttribute)"),
                                .target(name: "\(nameAttribute)Testing")
                            ]
                           ),
                    
                    // Testing target
                    .target(name: "\(nameAttribute)Testing",
                            destinations: [.mac, .iPhone],
                            product: .framework,
                            bundleId: "\(bundleIdAttribute).testing",
                            deploymentTargets: .multiplatform(macOS: "14.2"),
                            infoPlist: .default,
                            sources: ["Testing/**"],
                            dependencies: [
                                .target(name: "\(nameAttribute)Interface")
                            ]
                           )
                ]
            )
            """
        ),
        .directory(
            path: "Modules/\(nameAttribute)/Sources",
            sourcePath: "Sources"
        ),
        .directory(
            path: "Modules/\(nameAttribute)/Interface",
            sourcePath: "Interface"
        ),
        .directory(
            path: "Modules/\(nameAttribute)/Tests",
            sourcePath: "Tests"
        ),
        .directory(
            path: "Modules/\(nameAttribute)/Testing",
            sourcePath: "Testing"
        )
    ]
)
