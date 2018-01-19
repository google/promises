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

class PromiseAllTests: XCTestCase {
  func testPromiseAll() {
    // Arrange.
    let expectedValues: [Any?] = [42, "hello world", [42], nil]
    let promise1 = Promise<Any?> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<Any?> { fulfill, _ in
      Test.delay(1) {
        fulfill("hello world")
      }
    }
    let promise3 = Promise<Any?> { fulfill, _ in
      Test.delay(2) {
        fulfill([42])
      }
    }
    let promise4 = Promise<Any?> { fulfill, _ in
      Test.delay(3) {
        fulfill(nil)
      }
    }

    // Act.
    let combinedPromise = all([promise1, promise2, promise3, promise4]).then { value in
      XCTAssert(value == expectedValues)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value == expectedValues)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAllEmpty() {
    // Act.
    let promise = all([Promise<Any>]()).then { value in
      XCTAssert(value.isEmpty)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssert(promise.value?.isEmpty ?? false)
    XCTAssertNil(promise.error)
  }

  func testPromiseAllRejectFirst() {
    // Arrange.
    let promise1 = Promise { fulfill, _ in
      Test.delay(1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<Int> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = all([ promise1, promise2 ]).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAllRejectLast() {
    // Arrange.
    let promise1 = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<Int> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = all([promise1, promise2]).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAllNoDeallocUntilResolved() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<[Int]>?
    weak var weakExtendedPromise2: Promise<[Int]>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      let extendedPromise1 = all([promise])
      let extendedPromise2 = all([promise])
      weakExtendedPromise1 = extendedPromise1
      weakExtendedPromise2 = extendedPromise2
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    promise.fulfill(42)
    XCTAssert(waitForPromises(timeout: 10))

    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }
}
