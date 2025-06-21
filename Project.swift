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
            destinations: .iOS,
            product: .app,
            bundleId: "com.tvshowsapp.TVShowsApp",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["TVShowsApp/Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TVShowsAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.tvshowsapp.TVShowsAppTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["TVShowsApp/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TVShowsApp")]
        ),
    ],
    schemes: [
        
    ]
)
