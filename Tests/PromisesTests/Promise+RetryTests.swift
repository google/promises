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

import FBLPromises
import PromisesTestHelpers
import XCTest
@testable import Promises

class PromiseRetryTests: XCTestCase {
  static let initialAttemptCount = 1

  func testPromiseRetryWithDefaultRetryAttemptAfterInitialReject() {
    // Arrange.
    var count = PromiseRetryTests.initialAttemptCount + __FBLPromiseRetryDefaultAttemptsCount

    // Act.
    retry {
      count -= 1
      return count == 0 ? Promise(42) : Promise(Test.Error.code42)
    }.then { value in
      XCTAssertEqual(value, 42)
    }.catch { _ in
      XCTFail("Promise should not be resolved with error.")
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 0)
  }

  func testPromiseRetryNoRetryAttemptOnInitialFulfill() {
    // Arrange.
    var count = PromiseRetryTests.initialAttemptCount + __FBLPromiseRetryDefaultAttemptsCount

    // Act.
    retry {
      count -= 1
      return Promise(42)
    }.then { value in
      XCTAssertEqual(value, 42)
    }.catch { _ in
      XCTFail("Promise should not be resolved with error.")
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, __FBLPromiseRetryDefaultAttemptsCount)
  }

  func testPromiseRetryExhaustsAllRetryAttemptsBeforeRejection() {
    // Arrange.
    let customAttempts = 3
    var count = PromiseRetryTests.initialAttemptCount + customAttempts

    // Act.
    retry(attempts: customAttempts) { () -> Promise<Int> in
      count -= 1
      return Promise(Test.Error.code42)
    }.then { _ in
      XCTFail("Promise should not be resolved with value.")
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 0)
  }

  func testPromiseRetryAttemptMadeAfterDefaultDelay() {
    // Arrange.
    let customAttempts = 3
    var count = PromiseRetryTests.initialAttemptCount + customAttempts
    var startDate = Date()

    // Act.
    retry(attempts: customAttempts) {
      defer { startDate = Date() }
      if count <= customAttempts {
        let timeInterval = Date().timeIntervalSince(startDate).rounded()
        XCTAssertGreaterThanOrEqual(timeInterval, __FBLPromiseRetryDefaultDelayInterval)
      }
      count -= 1
      return count == 0 ? Promise(42) : Promise(Test.Error.code42)
    }.then { value in
      XCTAssertEqual(value, 42)
    }.catch { _ in
      XCTFail("Promise should not be resolved with error.")
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 0)
  }

  func testPromiseRetryAttemptMadeAfterCustomDelay() {
    // Arrange.
    let customDelay: TimeInterval = 2.0
    let customAttempts = 2
    var count = PromiseRetryTests.initialAttemptCount + customAttempts
    var startDate = Date()

    // Act.
    retry(attempts: customAttempts, delay: customDelay) { () -> Promise<Int> in
      defer { startDate = Date() }
      if count <= customAttempts {
        let timeInterval = Date().timeIntervalSince(startDate).rounded()
        XCTAssertGreaterThanOrEqual(timeInterval, customDelay)
      }
      count -= 1
      return count == 0 ? Promise(42) : Promise(Test.Error.code42)
    }.then { value in
      XCTAssertEqual(value, 42)
    }.catch { _ in
      XCTFail("Promise should not be resolved with error.")
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 0)
  }

  func testPromiseRetryRejectsBeforeRetryAttemptsAreExhaustedIfPredicateIsNotMet() {
    // Arrange.
    let customAttempts = 3
    var count = PromiseRetryTests.initialAttemptCount + customAttempts

    // Act.
    retry(attempts: customAttempts, condition: { remainingAttempts, error -> Bool in
      XCTAssertEqual(count, remainingAttempts)
      return error == Test.Error.code42
    }) { () -> Promise<Int> in
      count -= 1
      return count > 1 ? Promise(Test.Error.code42) : Promise(Test.Error.code13)
    }.then { _ in
      XCTFail("Promise should not be resolved with value.")
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code13)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 1)
  }

  func testPromiseRetryNoDeallocUntilResolved() {
    // Arrange.
    weak var weakExtendedPromise1: Promise<Int>?
    weak var weakExtendedPromise2: Promise<Int>?
    let customAttempts = 3
    var count = PromiseRetryTests.initialAttemptCount + customAttempts

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = retry { Promise(42) }
      weakExtendedPromise2 = retry(
        attempts: customAttempts,
        delay: 2.0,
        condition: { attempts, error -> Bool in
          XCTAssertEqual(count, attempts)
          return error == Test.Error.code42
        }
      ) { () -> Promise<Int> in
        count -= 1
        return count > 1 ? Promise(Test.Error.code42) : Promise(13)
      }
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    XCTAssert(waitForPromises(timeout: 15))
    XCTAssertEqual(count, 1)
    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }
}
