import ProjectDescription
import ProjectDescriptionHelpers

let configuration = CoreModuleConfiguration(
    name: "Networking"
)

let project = Project.tmaModule(
    configuration: configuration,
    additionalDependencies: [
        // Add module-specific dependencies here
    ]
)