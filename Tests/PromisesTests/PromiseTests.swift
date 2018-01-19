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

import PromisesTestHelpers
import XCTest
@testable import Promises

class PromiseTests: XCTestCase {
  func testPromiseConstructor() {
    // Arrange & Act.
    let promise = Promise<Void>.pending()

    // Assert.
    XCTAssertTrue(promise.isPending)
    XCTAssertNil(promise.value)
    XCTAssertNil(promise.error)
  }

  func testPromiseFulfill() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.fulfill(42)

    // Assert.
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseNoDoubleFulfill() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.fulfill(42)
    promise.fulfill(13)

    // Assert.
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseReject() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.reject(Test.Error.code42)

    // Assert.
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseNoDoubleReject() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.reject(Test.Error.code42)
    promise.reject(Test.Error.code13)

    // Assert.
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseNoRejectAfterFulfill() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.fulfill(42)
    promise.reject(Test.Error.code13)

    // Assert.
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseNoFulfillAfterReject() {
    // Arrange.
    let promise = Promise<Int>.pending()

    // Act.
    promise.reject(Test.Error.code42)
    promise.fulfill(13)

    // Assert.
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromisePendingDealloc() {
    weak var weakPromise: Promise<Int>?

    autoreleasepool {
      XCTAssertNil(weakPromise)
      let promise = Promise<Int>.pending()
      weakPromise = promise
      XCTAssertNotNil(weakPromise)
    }
    XCTAssertNil(weakPromise)
  }
}
