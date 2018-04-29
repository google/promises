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

class PromiseCatchTests: XCTestCase {
  func testPromiseDoesNotCallThenAfterReject() {
    // Act.
    let promise = Promise<AnyObject> {
      return Test.Error.code42 as AnyObject
    }.then { _ in
      XCTFail()
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertTrue(promise.value == nil)
  }

  func testPromiseDoesNotCallThenAfterAsyncReject() {
    // Act.
    let promise = Promise { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseCallsSubsequentCatchAfterReject() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<AnyObject> {
      return Test.Error.code42 as AnyObject
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 3)
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertTrue(promise.value == nil)
  }

  func testPromiseCallsSubsequentCatchAfterAsyncReject() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }.catch { error in
      XCTAssertEqual(error.code, 42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 3)
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseCatchesThrownError() {
    // Act.
    let promise = Promise<Void> {
      throw Test.Error.code42
    }.then { _ in
      XCTFail()
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
  }

  func testPromiseCatchesThrownErrorFromAsync() {
    // Act.
    let promise = Promise { _, _ in
      throw Test.Error.code42
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
  }

  func testPromiseNoCatchOnPending() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = Promise<Void>.pending()

    let thenPromise = promise.catch { _ in
      XCTFail()
    }
    Test.delay(0.1) {
      expectation.fulfill()
    }

    // Assert.
    waitForExpectations(timeout: 10)
    XCTAssert(promise.isPending)
    XCTAssertNil(promise.value)
    XCTAssertNil(promise.error)
    XCTAssert(thenPromise.isPending)
    XCTAssertNil(thenPromise.value)
    XCTAssertNil(thenPromise.error)
  }

  func testPromiseNoRejectAfterFulfill() {
    // Act.
    let promise = Promise { fulfill, reject in
      let error = Test.Error.code42
      fulfill(42)
      reject(error)
      throw error
    }.then { value in
      XCTAssertEqual(value, 42)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseNoFulfillAfterReject() {
    // Act.
    let promise = Promise<Int> { fulfill, reject in
      let error = Test.Error.code42
      reject(error)
      fulfill(42)
      throw error
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }.then {
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseNoDoubleReject() {
    // Act.
    let promise = Promise<Void> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
        reject(Test.Error.code13)
      }
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseThenReturnError() {
    // Act.
    let promise = Promise {
      return 42
    }.then { _ in
      return Test.Error.code42
    }.then { _ in
      XCTFail()
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseCatchInitiallyRejected() {
    // Act.
    let initiallyRejectedPromise = Promise(Test.Error.code42)
    let promise = initiallyRejectedPromise.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(initiallyRejectedPromise.error == Test.Error.code42)
    XCTAssertNil(initiallyRejectedPromise.value)
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseCatchNoDeallocUntilRejected() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<Int>?
    weak var weakExtendedPromise2: Promise<Int>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = promise.catch { _ in }
      weakExtendedPromise2 = promise.catch { _ in }
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
