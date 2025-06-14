import ProjectDescription

let project = Project(
    name: "TVShowsApp",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
            "IPHONEOS_DEPLOYMENT_TARGET": "15.0"
        ]
    ),
    targets: [
        .target(
            name: "TVShowsApp",
            destinations: [.mac, .iPhone],
            product: .app,
            bundleId: "br.com.cesarlima.Network",
            deploymentTargets: .multiplatform(macOS: "14.2"),
            infoPlist: .default,
            sources: ["TVShowsApp/Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TVShowsAppTests",
            destinations: [.mac, .iPhone],
            product: .unitTests,
            bundleId: "br.com.cesarlima.NetworkTests",
            deploymentTargets: .multiplatform(macOS: "14.2"),
            infoPlist: .default,
            sources: ["TVShowsApp/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TVShowsApp")]
        ),
    ]
)
