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

class PromiseRecoverTests: XCTestCase {
  func testPromiseRecover() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<Int> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.recover { error -> Promise<Int> in
      XCTAssertEqual(error.code, 42)
      count += 1
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          count += 1
          fulfill(42)
        }
      }
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 3)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseValueRecover() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.recover { error -> Int in
      XCTAssertEqual(error.code, 42)
      count += 1
      return 42
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 2)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseRecoverThrow() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<Int> { _, _ in
      throw Test.Error.code42
    }.recover { error -> Promise<Int> in
      XCTAssertTrue(error == Test.Error.code42)
      count += 1
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          count += 1
          fulfill(42)
        }
      }
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 3)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseRejectRecover() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<Void> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.recover { error -> Promise<Void> in
      XCTAssertTrue(error == Test.Error.code42)
      count += 1
      return Promise { _, reject in
        Test.delay(0.1) {
          count += 1
          reject(Test.Error.code13)
        }
      }
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code13)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 3)
    XCTAssertTrue(promise.error == Test.Error.code13)
    XCTAssertNil(promise.value)
  }

  func testPromiseThrowRecover() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<Void> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.recover { error -> Void in
      XCTAssertTrue(error == Test.Error.code42)
      count += 1
      throw Test.Error.code13
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code13)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 2)
    XCTAssertTrue(promise.error == Test.Error.code13)
    XCTAssertNil(promise.value)
  }

  func testPromiseRecoverNoDeallocUntilResolved() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<Int>?
    weak var weakExtendedPromise2: Promise<Int>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = promise.recover { _ in 42 }
      weakExtendedPromise2 = promise.recover { _ in 42 }
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    promise.reject(Test.Error.code42)
    XCTAssert(waitForPromises(timeout: 10))

    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }
}
