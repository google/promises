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

class PromiseAwaitTests: XCTestCase {
  func testPromiseAwaitFulfill() {
    // Act.
    let promise = Promise<Int>(on: .global()) { () -> Int in
      let minusFive = try await(Harness.negate(5))
      XCTAssertEqual(minusFive, -5)
      let twentyFive = try await(Harness.multiply(minusFive, minusFive))
      XCTAssertEqual(twentyFive, 25)
      let twenty = try await(Harness.add(twentyFive, minusFive))
      XCTAssertEqual(twenty, 20)
      let five = try await(Harness.subtract(twentyFive, twenty))
      XCTAssertEqual(five, 5)
      let zero = try await(Harness.add(minusFive, five))
      XCTAssertEqual(zero, 0)
      return try await(Harness.multiply(zero, five))
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise.value, 0)
    XCTAssertNil(promise.error)
  }

  func testPromiseAwaitReject() {
    // Arrange & Act.
    let promise = Promise<Int>(on: .global()) {
      return try await(Harness.fail(Test.Error.code42))
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  // MARK: - Private

  struct Harness {
    static func negate(_ number: Int) -> Promise<Int> {
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          fulfill(-number)
        }
      }
    }

    static func add(_ number: Int, _ number2: Int) -> Promise<Int> {
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          fulfill(number + number2)
        }
      }
    }

    static func subtract(_ number: Int, _ number2: Int) -> Promise<Int> {
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          fulfill(number - number2)
        }
      }
    }

    static func multiply(_ number: Int, _ number2: Int) -> Promise<Int> {
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          fulfill(number * number2)
        }
      }
    }

    static func fail(_ error: Error) -> Promise<Int> {
      return Promise { _, reject in
        Test.delay(0.1) {
          reject(error)
        }
      }
    }
  }
}
