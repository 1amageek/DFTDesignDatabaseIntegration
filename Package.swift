// swift-tools-version: 6.4
import PackageDescription

func releasedDependency(named name: String, exactVersion: Version) -> Package.Dependency {
    .package(
        url: "https://github.com/1amageek/\(name).git",
        exact: exactVersion
    )
}

let package = Package(
    name: "DFTDesignDatabaseIntegration",
    platforms: [.macOS("27.0")],
    products: [
        .library(name: "DFTDesignDatabaseSchema", targets: ["DFTDesignDatabaseSchema"]),
        .library(name: "DFTDesignDatabaseRuntimeAdapter", targets: ["DFTDesignDatabaseRuntimeAdapter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/1amageek/CircuiteFoundation.git", revision: "ae88104c556f5802819713ed741f5b2fffffc2d9"),
        .package(url: "https://github.com/1amageek/DesignDatabase.git", revision: "11df4ff7d905d642b5935defb3bc1fbcfefda038"),
        .package(url: "https://github.com/1amageek/DFTEngine.git", revision: "8afea931663c6e02af5e1ff59aac32d7a23d855f"),
        .package(url: "https://github.com/1amageek/LogicDesignDatabaseIntegration.git", revision: "20077f5a8a11b026289e0e4b4588e7afcd883fa6"),
        .package(url: "https://github.com/1amageek/StandardCellLibraryDesignDatabaseIntegration.git", revision: "f5b845171e5d30f563eb28d900c081f5f5f65c0a"),
        .package(url: "https://github.com/1amageek/TimingDesignDatabaseIntegration.git", revision: "3a7362281a1d2b6e9a4d7328422605f0e4a9b1c4"),
        .package(url: "https://github.com/1amageek/database-kit.git", exact: "26.0809.4"),
        .package(url: "https://github.com/1amageek/database-types.git", exact: "26.0730.0"),
        .package(
            url: "https://github.com/1amageek/database-framework.git",
            exact: "26.0809.1",
            traits: ["SQLite"]
        ),
    ],
    targets: [
        .target(
            name: "DFTDesignDatabaseSchema",
            dependencies: [
                .product(name: "CircuiteFoundation", package: "CircuiteFoundation"),
                .product(name: "CircuiteFoundationCrypto", package: "CircuiteFoundation"),
                .product(name: "DesignDatabaseCore", package: "DesignDatabase"),
                .product(name: "DFTCore", package: "DFTEngine"),
                .product(name: "LogicDesignDatabaseSchema", package: "LogicDesignDatabaseIntegration"),
                .product(name: "StandardCellLibraryDesignDatabaseSchema", package: "StandardCellLibraryDesignDatabaseIntegration"),
                .product(name: "TimingDesignDatabaseSchema", package: "TimingDesignDatabaseIntegration"),
                .product(name: "DatabaseKit", package: "database-kit"),
                .product(name: "DatabaseTypes", package: "database-types"),
                .product(name: "DatabaseTypesFoundation", package: "database-types"),
            ]
        ),
        .target(
            name: "DFTDesignDatabaseRuntimeAdapter",
            dependencies: [
                "DFTDesignDatabaseSchema",
                .product(name: "CircuiteFoundation", package: "CircuiteFoundation"),
                .product(name: "CircuiteFoundationCrypto", package: "CircuiteFoundation"),
                .product(name: "DesignDatabaseCore", package: "DesignDatabase"),
                .product(name: "DesignDatabaseRuntime", package: "DesignDatabase"),
                .product(name: "LogicDesignDatabaseSchema", package: "LogicDesignDatabaseIntegration"),
                .product(name: "StandardCellLibraryDesignDatabaseSchema", package: "StandardCellLibraryDesignDatabaseIntegration"),
                .product(name: "TimingDesignDatabaseSchema", package: "TimingDesignDatabaseIntegration"),
                .product(name: "Database", package: "database-framework"),
            ]
        ),
        .testTarget(
            name: "DFTDesignDatabaseIntegrationTests",
            dependencies: [
                "DFTDesignDatabaseSchema",
                "DFTDesignDatabaseRuntimeAdapter",
                .product(name: "CircuiteFoundation", package: "CircuiteFoundation"),
                .product(name: "DesignDatabaseCore", package: "DesignDatabase"),
                .product(name: "DFTCore", package: "DFTEngine"),
                .product(name: "LogicDesignDatabaseSchema", package: "LogicDesignDatabaseIntegration"),
                .product(name: "StandardCellLibraryDesignDatabaseSchema", package: "StandardCellLibraryDesignDatabaseIntegration"),
                .product(name: "TimingDesignDatabaseSchema", package: "TimingDesignDatabaseIntegration"),
            ]
        ),
    ]
)
