import ProjectDescription

// MARK: - Project Factory
extension Project {
    /// Creates a standard TMA module project
    static func tmaModule(
        configuration: ModuleConfiguration,
        additionalDependencies: [TargetDependency] = [],
        additionalSettings: SettingsDictionary = [:]
    ) -> Project {
        let targets = [
            // Implementation target
            Target.framework(
                name: configuration.name,
                bundleId: configuration.moduleBundleId,
                dependencies: [.target(name: configuration.interfaceName)] + additionalDependencies,
                additionalSettings: additionalSettings
            ),
            
            // Interface target
            Target.interface(
                name: configuration.interfaceName,
                bundleId: configuration.interfaceBundleId,
                additionalSettings: additionalSettings
            ),
            
            // Testing target
            Target.testing(
                name: configuration.testingName,
                bundleId: configuration.testingBundleId,
                interfaceTarget: configuration.interfaceName,
                additionalSettings: additionalSettings
            ),
            
            // Tests target
            Target.unitTests(
                name: configuration.testsName,
                bundleId: configuration.testsBundleId,
                implementationTarget: configuration.name,
                testingTarget: configuration.testingName,
                additionalSettings: additionalSettings
            )
        ]
        
        let schemes = [
            Scheme.module(
                name: configuration.name,
                implementationTarget: configuration.name,
                testsTarget: configuration.testsName
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
