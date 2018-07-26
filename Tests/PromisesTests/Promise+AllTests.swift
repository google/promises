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
    let expectedValues: [Int?] = [42, 13, nil]
    let promise1 = Promise<Int?> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<Int?> { fulfill, _ in
      Test.delay(1) {
        fulfill(13)
      }
    }
    let promise3 = Promise<Int?> { fulfill, _ in
      Test.delay(2) {
        fulfill(nil)
      }
    }

    // Act.
    let combinedPromise = all([promise1, promise2, promise3]).then { value in
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
      weakExtendedPromise1 = all([promise])
      weakExtendedPromise2 = all([promise])
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

  func testPromiseAllHeterogeneous2() {
    // Arrange.
    let expectedValues = (42, "hello world")
    let promise1 = Promise<Int> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { fulfill, _ in
      Test.delay(1) {
        fulfill("hello world")
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2).then { value in
      XCTAssert(value == expectedValues)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value == expectedValues)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAllHeterogeneous2Reject() {
    // Arrange.
    let promise1 = Promise<Int> { fulfill, _ in
      Test.delay(1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAllHeterogeneous2NoDeallocUntilResolved() {
    // Arrange.
    let promise1 = Promise<Int>.pending()
    let promise2 = Promise<String>.pending()
    weak var weakExtendedPromise1: Promise<(Int, String)>?
    weak var weakExtendedPromise2: Promise<(Int, String)>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = all(promise1, promise2)
      weakExtendedPromise2 = all(promise1, promise2)
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    promise1.fulfill(42)
    promise2.fulfill("hello world")
    XCTAssert(waitForPromises(timeout: 10))

    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }

  func testPromiseAllHeterogeneous3() {
    // Arrange.
    let expectedValues = (42, "hello world", Int?.none)
    let promise1 = Promise<Int> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { fulfill, _ in
      Test.delay(1) {
        fulfill("hello world")
      }
    }
    let promise3 = Promise<Int?> { fulfill, _ in
      Test.delay(2) {
        fulfill(nil)
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2, promise3).then { number, string, none in
      XCTAssert(number == expectedValues.0)
      XCTAssert(string == expectedValues.1)
      XCTAssert(none == expectedValues.2)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value.0 == expectedValues.0)
    XCTAssert(value.1 == expectedValues.1)
    XCTAssert(value.2 == expectedValues.2)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAllHeterogeneous3Reject() {
    // Arrange.
    let promise1 = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }
    let promise3 = Promise<Int?> { fulfill, _ in
      Test.delay(2) {
        fulfill(nil)
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2, promise3).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAllHeterogeneous3NoDeallocUntilResolved() {
    // Arrange.
    let promise1 = Promise<Int>.pending()
    let promise2 = Promise<String>.pending()
    let promise3 = Promise<Int?>.pending()
    weak var weakExtendedPromise1: Promise<(Int, String, Int?)>?
    weak var weakExtendedPromise2: Promise<(Int, String, Int?)>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = all(promise1, promise2, promise3)
      weakExtendedPromise2 = all(promise1, promise2, promise3)
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    promise1.fulfill(42)
    promise2.fulfill("hello world")
    promise3.fulfill(nil)
    XCTAssert(waitForPromises(timeout: 10))

    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }

  func testPromiseAllHeterogeneous4() {
    // Arrange.
    let expectedValues = (42, "hello world", Int?.none, 2.4)
    let promise1 = Promise<Int> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { fulfill, _ in
      Test.delay(1) {
        fulfill("hello world")
      }
    }
    let promise3 = Promise<Int?> { fulfill, _ in
      Test.delay(2) {
        fulfill(nil)
      }
    }
    let promise4 = Promise<Double> { fulfill, _ in
      Test.delay(3) {
        fulfill(2.4)
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2, promise3, promise4).then { number, string, none, double in
      XCTAssert(number == expectedValues.0)
      XCTAssert(string == expectedValues.1)
      XCTAssert(none == expectedValues.2)
      XCTAssert(double == expectedValues.3)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value.0 == expectedValues.0)
    XCTAssert(value.1 == expectedValues.1)
    XCTAssert(value.2 == expectedValues.2)
    XCTAssert(value.3 == expectedValues.3)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAllHeterogeneous4Reject() {
    // Arrange.
    let promise1 = Promise { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }
    let promise3 = Promise<Int?> { fulfill, _ in
      Test.delay(2) {
        fulfill(nil)
      }
    }
    let promise4 = Promise<Double> { fulfill, _ in
      Test.delay(3) {
        fulfill(2.4)
      }
    }

    // Act.
    let combinedPromise = all(promise1, promise2, promise3, promise4).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAllHeterogeneous4NoDeallocUntilResolved() {
    // Arrange.
    let promise1 = Promise<Int>.pending()
    let promise2 = Promise<String>.pending()
    let promise3 = Promise<Int?>.pending()
    let promise4 = Promise<Double>.pending()
    weak var weakExtendedPromise1: Promise<(Int, String, Int?, Double)>?
    weak var weakExtendedPromise2: Promise<(Int, String, Int?, Double)>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = all(promise1, promise2, promise3, promise4)
      weakExtendedPromise2 = all(promise1, promise2, promise3, promise4)
      XCTAssertNotNil(weakExtendedPromise1)
      XCTAssertNotNil(weakExtendedPromise2)
    }

    // Assert.
    XCTAssertNotNil(weakExtendedPromise1)
    XCTAssertNotNil(weakExtendedPromise2)

    promise1.fulfill(42)
    promise2.fulfill("hello world")
    promise3.fulfill(nil)
    promise4.fulfill(2.4)
    XCTAssert(waitForPromises(timeout: 10))

    XCTAssertNil(weakExtendedPromise1)
    XCTAssertNil(weakExtendedPromise2)
  }
}
