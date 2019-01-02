// swift-tools-version:4.2
// swiftlint:disable line_length
// swiftlint:disable trailing_comma

// To generate and open project in Xcode run:
// swift package -Xswiftc -ISources/FBLPromises/include generate-xcodeproj && open Promises.xcworkspace

// Copyright 2018 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
  name: "Promises",
  products: [
    .library(
      name: "FBLPromises",
      targets: [
        "FBLPromises",
      ]
    ),
    .library(
      name: "FBLPromisesTestHelpers",
      targets: [
        "FBLPromisesTestHelpers",
      ]
    ),
    .library(
      name: "Promises",
      targets: [
        "Promises",
      ]
    ),
    .library(
      name: "PromisesTestHelpers",
      targets: [
        "PromisesTestHelpers",
      ]
    ),
  ],
  targets: [
    .target(
      name: "FBLPromises"
    ),
    .target(
      name: "FBLPromisesTestHelpers",
      dependencies: [
        "FBLPromises",
      ]
    ),
    .testTarget(
      name: "FBLPromisesTests",
      dependencies: [
        "FBLPromisesTestHelpers",
      ]
    ),
    .testTarget(
      name: "FBLPromisesInteroperabilityTests",
      dependencies: [
        "FBLPromisesTestHelpers",
        "PromisesTestHelpers",
      ]
    ),
    .testTarget(
      name: "FBLPromisesPerformanceTests",
      dependencies: [
        "FBLPromisesTestHelpers",
      ]
    ),
    .target(
      name: "Promises",
      dependencies: [
        "FBLPromises",
      ]
    ),
    .target(
      name: "PromisesTestHelpers",
      dependencies: [
        "Promises",
      ]
    ),
    .testTarget(
      name: "PromisesTests",
      dependencies: [
        "PromisesTestHelpers",
      ]
    ),
    .testTarget(
      name: "PromisesInteroperabilityTests",
      dependencies: [
        "FBLPromisesTestHelpers",
        "PromisesTestHelpers",
      ]
    ),
    .testTarget(
      name: "PromisesPerformanceTests",
      dependencies: [
        "FBLPromisesTestHelpers",
        "PromisesTestHelpers",
      ]
    ),
  ]
)
