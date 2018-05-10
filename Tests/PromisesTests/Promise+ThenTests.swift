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

class PromiseThenTests: XCTestCase {
  func testPromiseThen() {
    // Act.
    let numberPromise = Promise { fulfill, _ in
      fulfill(42)
    }
    let stringPromise = numberPromise.then { number in
      return Promise { fulfill, _ in
        fulfill(String(number))
      }
    }
    typealias Block = (Int) -> [Int]
    let blockPromise = stringPromise.then { value in
      return Promise<Block> { fulfill, _ in
        fulfill({ number in
          return [number + (Int(value) ?? 0)]
        })
      }
    }
    let finalPromise = blockPromise.then { (value: @escaping Block) -> Int? in
      return value(42).first
    }
    let postFinalPromise = finalPromise.then { number in
      return number ?? 0
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(numberPromise.value, 42)
    XCTAssertNil(numberPromise.error)
    XCTAssertEqual(stringPromise.value, "42")
    XCTAssertNil(stringPromise.error)
    XCTAssertNotNil(blockPromise.value)
    let array = blockPromise.value?(42) ?? []
    XCTAssertEqual(array.count, 1)
    XCTAssertEqual(array.first, 84)
    XCTAssertNil(blockPromise.error)
    XCTAssertEqual(finalPromise.value ?? 0, 84)
    XCTAssertNil(finalPromise.error)
    XCTAssertEqual(postFinalPromise.value, 84)
    XCTAssertNil(postFinalPromise.error)
  }

  func testPromiseAsyncFulfill() {
    // Act.
    let promise = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }.then { number in
      XCTAssertEqual(number, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseChainedFulfill() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise<Int> {
      return 42
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 2)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseChainedAsyncFulfill() {
    // Arrange.
    var count = 0

    // Act.
    let promise = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }.then { value in
      XCTAssertEqual(value, 42)
      count += 1
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 2)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseNoThenOnPending() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = Promise<Void>.pending()

    let thenPromise = promise.then { _ in
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

  func testPromiseNoDoubleFulfill() {
    // Act.
    let promise = Promise<Int> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
        fulfill(13)
      }
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseThenInitiallyFulfilled() {
    // Act.
    let initiallyFulfilledPromise = Promise(42)
    let promise = initiallyFulfilledPromise.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(initiallyFulfilledPromise.value, 42)
    XCTAssertNil(initiallyFulfilledPromise.error)
    XCTAssertEqual(promise.value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseThenNoDeallocUntilFulfilled() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<Int>?
    weak var weakExtendedPromise2: Promise<Int>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = promise.then { _ in }
      weakExtendedPromise2 = promise.then { _ in }
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
