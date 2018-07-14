PROJECT_VERSION = '1.2.3'

BUNDLE_IDENTIFIER_PREFIX = 'com.google.'

OBJC_COPTS = [
    "-fobjc-arc",
    "-Werror",
    "-Wextra",
    "-Wall",
    "-Wstrict-prototypes",
    "-Wdocumentation",
]

SWIFT_VERSION = "4"

SWIFT_COPTS = [
    "-wmo",
]

apple_library(
    name = "Promises",
    srcs = glob([
        "Sources/Promises/*.swift",
    ]),
    swift_version = SWIFT_VERSION,
    compiler_flags = SWIFT_COPTS,
    modular = True,
    tests = [
        ":PromisesPerformanceTests",
        ":PromisesTests",
    ],
    deps = [
        ":FBLPromises",
    ],
    licenses = [
        "LICENSE",
    ],
    visibility = ["PUBLIC"],
)

apple_library(
    name = "PromisesTestHelpers",
    srcs = glob([
        "Sources/PromisesTestHelpers/*.swift",
    ]),
    swift_version = SWIFT_VERSION,
    compiler_flags = SWIFT_COPTS,
    modular = True,
    deps = [
        ":Promises",
    ],
)

apple_library(
    name = "FBLPromises",
    srcs = glob([
        "Sources/FBLPromises/*.m",
    ]),
    headers = glob([
        "Sources/FBLPromises/include/*.h",
    ]),
    exported_headers = glob([
        "Sources/FBLPromises/include/*.h",
    ]),
    compiler_flags = OBJC_COPTS,
    modular = True,
    tests = [
        ":FBLPromisesPerformanceTests",
        ":FBLPromisesTests",
    ],
    licenses = [
        "LICENSE",
    ],
    visibility = ["PUBLIC"],
)

apple_library(
    name = "FBLPromisesTestHelpers",
    srcs = glob([
        "Sources/FBLPromisesTestHelpers/*.m",
    ]),
    headers = glob([
        "Sources/FBLPromisesTestHelpers/include/*.h",
    ]),
    exported_headers = glob([
        "Sources/FBLPromisesTestHelpers/include/*.h",
    ]),
    compiler_flags = OBJC_COPTS,
    preprocessor_flags = [
        "-ISources/FBLPromises/include",
    ],
    modular = True,
    deps = [
        ":FBLPromises",
    ],
)

apple_test(
    name = "PromisesTests",
    info_plist = "Promises.xcodeproj/PromisesTests_Info.plist",
    info_plist_substitutions = {
        'CURRENT_PROJECT_VERSION' : PROJECT_VERSION,
        'PRODUCT_BUNDLE_IDENTIFIER' : BUNDLE_IDENTIFIER_PREFIX + 'PromisesTests',
    },
    srcs = glob([
        "Tests/PromisesTests/*.swift",
    ]),
    swift_version = SWIFT_VERSION,
    compiler_flags = SWIFT_COPTS,
    deps = [
        ":PromisesTestHelpers",
    ],
    frameworks = [
        "$SDKROOT/System/Library/Frameworks/Foundation.framework",
        "$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework",
    ],
)

apple_test(
    name = "PromisesPerformanceTests",
    info_plist = "Promises.xcodeproj/PromisesPerformanceTests_Info.plist",
    info_plist_substitutions = {
        'CURRENT_PROJECT_VERSION' : PROJECT_VERSION,
        'PRODUCT_BUNDLE_IDENTIFIER' : BUNDLE_IDENTIFIER_PREFIX + 'PromisesPerformanceTests',
    },
    srcs = glob([
        "Tests/PromisesPerformanceTests/*.swift",
    ]),
    swift_version = SWIFT_VERSION,
    compiler_flags = SWIFT_COPTS,
    deps = [
        ":FBLPromisesTestHelpers",
        ":PromisesTestHelpers",
    ],
    frameworks = [
        "$SDKROOT/System/Library/Frameworks/Foundation.framework",
        "$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework",
    ],
)

apple_test(
    name = "FBLPromisesTests",
    info_plist = "Promises.xcodeproj/FBLPromisesTests_Info.plist",
    info_plist_substitutions = {
        'CURRENT_PROJECT_VERSION' : PROJECT_VERSION,
        'PRODUCT_BUNDLE_IDENTIFIER' : BUNDLE_IDENTIFIER_PREFIX + 'FBLPromisesTests',
    },
    srcs = glob([
        "Tests/FBLPromisesTests/*.m",
    ]),
    compiler_flags = OBJC_COPTS,
    preprocessor_flags = [
        "-ISources/FBLPromises/include",
        "-ISources/FBLPromisesTestHelpers/include",
    ],
    deps = [
        ":FBLPromisesTestHelpers",
    ],
    frameworks = [
        "$SDKROOT/System/Library/Frameworks/Foundation.framework",
        "$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework",
    ],
)

apple_test(
    name = "FBLPromisesPerformanceTests",
    info_plist = "Promises.xcodeproj/FBLPromisesPerformanceTests_Info.plist",
    info_plist_substitutions = {
        'CURRENT_PROJECT_VERSION' : PROJECT_VERSION,
        'PRODUCT_BUNDLE_IDENTIFIER' : BUNDLE_IDENTIFIER_PREFIX + 'FBLPromisesPerformanceTests',
    },
    srcs = glob([
        "Tests/FBLPromisesPerformanceTests/*.m",
    ]),
    compiler_flags = OBJC_COPTS,
    preprocessor_flags = [
        "-ISources/FBLPromises/include",
        "-ISources/FBLPromisesTestHelpers/include",
    ],
    deps = [
        ":FBLPromisesTestHelpers",
    ],
    frameworks = [
        "$SDKROOT/System/Library/Frameworks/Foundation.framework",
        "$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework",
    ],
)
