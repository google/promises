package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

exports_files(["LICENSE"])

load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

OBJC_COPTS = [
    "-Werror",
    "-Wextra",
    "-Wall",
    "-Wstrict-prototypes",
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
    copts = [],
    module_name = "PromisesTestHelpers",
    deps = [
        ":Promises",
    ],
)

objc_library(
    name = "FBLPromises",
    srcs = glob([
        "Sources/FBLPromises/*.m",
    ]),
    hdrs = glob([
        "Sources/FBLPromises/include/*.h",
    ]) + [
        "FBLPromises.h",
        "FBLPromise+Testing.h",
    ],
    copts = OBJC_COPTS,
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
    minimum_os_version = "8.0",
    test_host = "@build_bazel_rules_apple//apple/testing/default_host/ios",
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
    copts = SWIFT_COPTS + [
        "-swift-version",
        "4",
    ],
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
