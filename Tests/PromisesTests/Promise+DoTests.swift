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

class PromiseDoTests: XCTestCase {
  func testPromiseDoFulfill() {
    // Arrange & Act.
    let promise = Promise<Int> { 42 }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseDoReturnPromise() {
    // Arrange & Act.
    let promise = Promise<Int> { Promise(42) }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseDoReject() {
    // Arrange & Act.
    let promise = Promise<Int> { throw Test.Error.code42 }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseDoNoDeallocUntilFulfilled() {
    // Arrange.
    weak var weakPromise1: Promise<Int>?
    weak var weakPromise2: Promise<Int>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakPromise1)
      XCTAssertNil(weakPromise2)
      weakPromise1 = Promise<Int> { 42 }
      weakPromise2 = Promise<Int> { 42 }
      XCTAssertNotNil(weakPromise1)
      XCTAssertNotNil(weakPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakPromise1)
    XCTAssertNotNil(weakPromise2)
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertNil(weakPromise1)
    XCTAssertNil(weakPromise2)
  }
}
