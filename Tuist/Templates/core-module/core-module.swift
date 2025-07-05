//
//  CoreModule.swift
//  Config
//
//  Created by MacPro on 14/06/25.
//

import ProjectDescription

fileprivate let moduleName: Template.Attribute = .required("name")

let template = Template(
    description: "A template for core modules following TMA architecture",
    attributes: [
        moduleName,
        .optional("platform", default: "ios"),
    ],
    items: [
        .string(
            path: "Modules/Core/\(moduleName)/Project.swift",
            contents: """
            import ProjectDescription
            import ProjectDescriptionHelpers

            let configuration = CoreModuleConfiguration(
                name: "\(moduleName)"
            )

            let project = Project.tmaModule(
                configuration: configuration,
                additionalDependencies: [
                    // Add module-specific dependencies here
                ]
            )
            """
        ),
        .file(
            path: "Modules/Core/\(moduleName)/\(moduleName)/Module.swift",
            templatePath: "Sources/Module.swift"
        ),
        .file(
            path: "Modules/Core/\(moduleName)/\(moduleName)Interface/ModuleInterface.swift",
            templatePath: "Interface/ModuleInterface.swift"
        ),
        .file(
            path: "Modules/Core/\(moduleName)/\(moduleName)Tests/ModuleTests.swift",
            templatePath: "Tests/ModuleTests.stencil"
        ),
        .file(
            path: "Modules/Core/\(moduleName)/\(moduleName)Testing/ModuleTesting.swift",
            templatePath: "Testing/ModuleTesting.swift"
        )
    ]
)
