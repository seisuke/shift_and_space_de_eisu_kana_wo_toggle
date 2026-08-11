// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "shift_and_space_de_eisu_kana_wo_toggle",
    platforms: [.macOS(.v26)],
    products: [
        .executable(
            name: "shift_and_space_de_eisu_kana_wo_toggle",
            targets: ["ShiftSpaceToggle"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ShiftSpaceToggle",
            path: "Sources/ShiftSpaceToggle",
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault")
            ],
            linkerSettings: [
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "ShiftSpaceToggleTests",
            dependencies: ["ShiftSpaceToggle"],
            path: "Tests/ShiftSpaceToggleTests",
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)
