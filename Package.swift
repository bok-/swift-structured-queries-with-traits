// swift-tools-version: 6.1

import CompilerPluginSupport
import PackageDescription

#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

let package = Package(
  name: "swift-structured-queries",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "StructuredQueries",
      targets: ["StructuredQueries"]
    ),
    .library(
      name: "StructuredQueriesCore",
      targets: ["StructuredQueriesCore"]
    ),
    .library(
      name: "StructuredQueriesSQLite",
      targets: ["StructuredQueriesSQLite"]
    ),
    .library(
      name: "StructuredQueriesSQLiteCore",
      targets: ["StructuredQueriesSQLiteCore"]
    ),
    .library(
      name: "StructuredQueriesTestSupport",
      targets: ["StructuredQueriesTestSupport"]
    ),
  ],
  traits: [
    .trait(
      name: "StructuredQueriesCasePaths",
      description: "Introduce enum table support to StructuredQueries."
    ),
    .trait(
      name: "StructuredQueriesTagged",
      description: "Introduce StructuredQueries conformances to the swift-tagged package."
    ),
    .trait(
      name: "StructuredQueriesCustomDump",
      description: "Include swift-custom-dump support."
    ),
    .trait(
      name: "StructuredQueriesDependencies",
      description: "Include swift-dependencies support."
    ),
    .trait(
      name: "StructuredQueriesMacroTesting",
      description:
        "Include swift-macro-testing support. Generally only needed when running unit tests."
    ),
    .trait(
      name: "StructuredQueriesSnapshotTesting",
      description:
        "Include swift-snapshot-testing support. Generally only needed when running unit tests."
    ),
    .trait(
      name: "StructuredQueriesIssueReporting",
      description: "Include swift-issue-reporting (nee xctest-dynamic-overlay) support."
    ),
  ],
  dependencies: [
    .package(
        url: "https://github.com/bok-/swift-case-paths-with-traits",
        from: "1.7.2+traits",
        traits: [
            .trait(
                name: "CasePathsIssueReporting",
                condition: .when(traits: ["StructuredQueriesIssueReporting"])
            )
        ]
    ),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.8.1"),
    .package(url: "https://github.com/bok-/swift-macro-testing-with-traits", from: "0.6.4+traits"),
    .package(
      url: "https://github.com/bok-/swift-snapshot-testing-with-traits",
      exact: "1.18.7+traits",
      traits: [
        .trait(
          name: "SnapshotTestingCustomDump",
          condition: .when(traits: ["StructuredQueriesCustomDump"]))
      ]
    ),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.2"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"603.0.0"),
  ],
  targets: [
    .target(
      name: "StructuredQueries",
      dependencies: [
        "StructuredQueriesCore",
        "StructuredQueriesMacros",
      ]
    ),
    .target(
      name: "StructuredQueriesCore",
      dependencies: [
        .product(
          name: "IssueReporting",
          package: "xctest-dynamic-overlay",
          condition: .when(traits: ["StructuredQueriesIssueReporting"])
        ),
        .product(
          name: "CasePaths",
          package: "swift-case-paths-with-traits",
          condition: .when(traits: ["StructuredQueriesCasePaths"])
        ),
        .product(
          name: "Tagged",
          package: "swift-tagged",
          condition: .when(traits: ["StructuredQueriesTagged"])
        ),
      ],
      exclude: ["Symbolic Links/README.md"]
    ),
    .macro(
      name: "StructuredQueriesMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ],
      exclude: ["Symbolic Links/README.md"]
    ),

    .target(
      name: "StructuredQueriesSQLite",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesSQLiteCore",
        "StructuredQueriesSQLiteMacros",
      ]
    ),
    .target(
      name: "StructuredQueriesSQLiteCore",
      dependencies: [
        "StructuredQueriesCore"
      ]
    ),
    .macro(
      name: "StructuredQueriesSQLiteMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),

    .target(
      name: "StructuredQueriesTestSupport",
      dependencies: [
        "StructuredQueriesCore",
        .product(
          name: "CustomDump",
          package: "swift-custom-dump",
          condition: .when(traits: ["StructuredQueriesCustomDump"])
        ),
        .product(
          name: "InlineSnapshotTesting",
          package: "swift-snapshot-testing-with-traits",
          condition: .when(traits: ["StructuredQueriesSnapshotTesting"])
        ),
      ]
    ),
    .testTarget(
      name: "StructuredQueriesMacrosTests",
      dependencies: [
        "StructuredQueriesMacros",
        "StructuredQueriesSQLiteMacros",
        .product(
          name: "IssueReporting",
          package: "xctest-dynamic-overlay",
          condition: .when(traits: ["StructuredQueriesIssueReporting"])
        ),
        .product(
          name: "MacroTesting",
          package: "swift-macro-testing-with-traits",
          condition: .when(traits: ["StructuredQueriesMacroTesting"])
        ),
      ]
    ),
    .testTarget(
      name: "StructuredQueriesTests",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesSQLite",
        "StructuredQueriesTestSupport",
        "_StructuredQueriesSQLite",
        .product(
          name: "CustomDump",
          package: "swift-custom-dump",
          condition: .when(traits: ["StructuredQueriesCustomDump"])
        ),
        .product(
          name: "Dependencies",
          package: "swift-dependencies",
          condition: .when(traits: ["StructuredQueriesDependencies"])
        ),
        .product(
          name: "InlineSnapshotTesting",
          package: "swift-snapshot-testing-with-traits",
          condition: .when(traits: ["StructuredQueriesSnapshotTesting"])
        ),
      ]
    ),

    .target(
      name: "_StructuredQueriesSQLite",
      dependencies: [
        "StructuredQueriesSQLite"
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)

if ProcessInfo.processInfo.environment["SPI_GENERATE_DOCS"] != nil
  || ProcessInfo.processInfo.environment["GITHUB_ACTION"] != nil
  // || true  // NB: Uncomment for local testing in Xcode
{
  package.traits.insert(
    .default(
      enabledTraits: [
        "StructuredQueriesCasePaths",
        "StructuredQueriesTagged",
      ]
    )
  )
}

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("MemberImportVisibility")
  // .unsafeFlags([
  //   "-Xfrontend",
  //   "-warn-long-function-bodies=50",
  //   "-Xfrontend",
  //   "-warn-long-expression-type-checking=50",
  // ])
]

for index in package.targets.indices {
  package.targets[index].swiftSettings = swiftSettings
}

#if !canImport(Darwin)
  package.targets.append(
    .systemLibrary(
      name: "_StructuredQueriesSQLite3",
      providers: [.apt(["libsqlite3-dev"])]
    )
  )

  for index in package.targets.indices {
    if package.targets[index].name == "_StructuredQueriesSQLite" {
      package.targets[index].dependencies.append("_StructuredQueriesSQLite3")
    }
  }
#endif

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
  )
#endif
