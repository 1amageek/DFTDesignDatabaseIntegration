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
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "DFTDesignDatabaseSchema", targets: ["DFTDesignDatabaseSchema"]),
        .library(name: "DFTDesignDatabaseRuntimeAdapter", targets: ["DFTDesignDatabaseRuntimeAdapter"]),
    ],
    dependencies: [
        releasedDependency(named: "CircuiteFoundation", exactVersion: "26.812.0"),
        .package(url: "https://github.com/1amageek/DesignDatabase.git", revision: "11df4ff7d905d642b5935defb3bc1fbcfefda038"),
        .package(url: "https://github.com/1amageek/DFTEngine.git", revision: "c10576a1af7e1ed30d5d2ba6d7a04c08cc4f7398"),
        .package(url: "https://github.com/1amageek/LogicDesignDatabaseIntegration.git", revision: "7a6a6dc364f9d93fd040762693a550211d6301ff"),
        .package(url: "https://github.com/1amageek/StandardCellLibraryDesignDatabaseIntegration.git", revision: "dcdd1d5224ace1470b1d1bdfd25594280d6a13a6"),
        .package(url: "https://github.com/1amageek/TimingDesignDatabaseIntegration.git", revision: "c1ed6ff9ebfd68b96113c9e9227d7edbb2bc5c27"),
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
