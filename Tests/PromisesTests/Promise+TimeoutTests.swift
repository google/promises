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

class PromiseTimeoutTests: XCTestCase {
  func testPromiseTimeoutSuccess() {
    // Act.
    let promise = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }.timeout(1).catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseTimeoutFail() {
    // Act.
    let promise = Promise { fulfill, _ in
      Test.delay(1) {
        fulfill(42)
      }
    }.timeout(0.1).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error is PromiseError)
      XCTAssertTrue(error == PromiseError.timedOut)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error is PromiseError)
    XCTAssertTrue(promise.error == PromiseError.timedOut)
    XCTAssertNil(promise.value)
  }

  func testPromiseTimeoutNoDeallocUntilResolved() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<Int>?
    weak var weakExtendedPromise2: Promise<Int>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = promise.timeout(1)
      weakExtendedPromise2 = promise.timeout(1)
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
