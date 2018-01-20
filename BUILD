package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

OBJC_COPTS = [
    "-Werror",
    "-Wextra",
    "-Wall",
    "-Wdocumentation",
]

SWIFT_COPTS = [
    "-wmo",
]

swift_library(
    name = "Promises",
    srcs = glob([
        "Sources/Promises/*.swift",
    ]),
    copts = SWIFT_COPTS,
    module_name = "Promises",
    deps = [
        ":FBLPromises",
    ],
)

swift_library(
    name = "PromisesTestHelpers",
    testonly = 1,
    srcs = glob([
        "Sources/PromisesTestHelpers/*.swift",
    ]),
    copts = SWIFT_COPTS,
    module_name = "PromisesTestHelpers",
    deps = [
        ":Promises",
    ],
)

objc_library(
    name = "FBLPromises",
    srcs = glob([
        "Sources/FBLPromises/*.m",
        "Sources/FBLPromises/DotSyntax/*.m",
    ]),
    hdrs = glob([
        "Sources/FBLPromises/include/*.h",
        "Sources/FBLPromises/include/DotSyntax/*.h",
    ]) + [
        "FBLPromises.h",
    ],
    copts = OBJC_COPTS,
    defines = [
        "FBL_PROMISES_DOT_SYNTAX_IS_DEPRECATED",
    ],
    includes = [
        "Sources/FBLPromises/include",
    ],
    module_map = "Sources/FBLPromises/include/module.modulemap",
)

objc_library(
    name = "FBLPromisesTestHelpers",
    testonly = 1,
    srcs = glob([
        "Sources/FBLPromisesTestHelpers/*.m",
    ]),
    hdrs = glob([
        "Sources/FBLPromisesTestHelpers/include/*.h",
    ]),
    copts = OBJC_COPTS,
    includes = [
        "Sources/FBLPromisesTestHelpers/include",
    ],
    module_map = "Sources/FBLPromisesTestHelpers/include/module.modulemap",
    deps = [
        ":FBLPromises",
    ],
)

ios_unit_test(
    name = "Tests",
    deps = [
        ":FBLPromisesInteroperabilityTests",
        ":FBLPromisesPerformanceTests",
        ":FBLPromisesTests",
        ":PromisesInteroperabilityTests",
        ":PromisesPerformanceTests",
        ":PromisesTests",
    ],
)

swift_library(
    name = "PromisesTests",
    testonly = 1,
    srcs = glob([
        "Tests/PromisesTests/*.swift",
    ]),
    copts = SWIFT_COPTS,
    deps = [
        ":PromisesTestHelpers",
    ],
)

swift_library(
    name = "PromisesInteroperabilityTests",
    testonly = 1,
    srcs = glob([
        "Tests/PromisesInteroperabilityTests/*.swift",
    ]),
    copts = SWIFT_COPTS,
    deps = [
        ":FBLPromisesTestHelpers",
        ":PromisesTestHelpers",
    ],
)

swift_library(
    name = "PromisesPerformanceTests",
    testonly = 1,
    srcs = glob([
        "Tests/PromisesPerformanceTests/*.swift",
    ]),
    copts = SWIFT_COPTS,
    swift_version = 4,
    deps = [
        ":FBLPromisesTestHelpers",
        ":PromisesTestHelpers",
    ],
)

objc_library(
    name = "FBLPromisesTests",
    testonly = 1,
    srcs = glob([
        "Tests/FBLPromisesTests/*.m",
    ]),
    copts = OBJC_COPTS,
    deps = [
        ":FBLPromisesTestHelpers",
    ],
)

objc_library(
    name = "FBLPromisesInteroperabilityTests",
    testonly = 1,
    srcs = glob([
        "Tests/FBLPromisesInteroperabilityTests/*.m",
    ]),
    copts = OBJC_COPTS,
    includes = [
        "../Promises",
    ],
    deps = [
        ":FBLPromisesTestHelpers",
        ":PromisesTestHelpers",
    ],
)

objc_library(
    name = "FBLPromisesPerformanceTests",
    testonly = 1,
    srcs = glob([
        "Tests/FBLPromisesPerformanceTests/*.m",
    ]),
    copts = OBJC_COPTS,
    deps = [
        ":FBLPromisesTestHelpers",
    ],
)
