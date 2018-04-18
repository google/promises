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

class PromiseAnyTests: XCTestCase {
  func testPromiseAny() {
    // Arrange.
    let expectedValues = [Maybe(42), Maybe(13), Maybe<Int?>(nil)]
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
    let combinedPromise = any([promise1, promise2, promise3]).then { value in
      XCTAssert(value == expectedValues)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value == expectedValues)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyEmpty() {
    // Act.
    let promise = any([Promise<Any>]()).then { value in
      XCTAssert(value.isEmpty)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssert(promise.value?.isEmpty ?? false)
    XCTAssertNil(promise.error)
  }

  func testPromiseAnyRejectFirst() {
    // Arrange.
    let expectedValuesAndErrors = [Maybe(42), Maybe(Test.Error.code42)]
    let promise1 = Promise<Int> { fulfill, _ in
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
    let combinedPromise = any([promise1, promise2]).then { value in
      XCTAssert(value == expectedValuesAndErrors)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value == expectedValuesAndErrors)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyRejectLast() {
    // Arrange.
    let expectedValuesAndErrors = [Maybe(42), Maybe(Test.Error.code42)]
    let promise1 = Promise<Int> { fulfill, _ in
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
    let combinedPromise = any([promise1, promise2]).then { value in
      XCTAssert(value == expectedValuesAndErrors)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value == expectedValuesAndErrors)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyRejectAll() {
    // Arrange.
    let promise1 = Promise<Void> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code13)
      }
    }
    let promise2 = Promise<Void> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = any([promise1, promise2]).then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAnyNoDeallocUntilResolved() {
    // Arrange.
    let promise = Promise<Int>.pending()
    weak var weakExtendedPromise1: Promise<[Maybe<Int>]>?
    weak var weakExtendedPromise2: Promise<[Maybe<Int>]>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = any([promise])
      weakExtendedPromise2 = any([promise])
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

  func testPromiseAnyHeterogeneous2() {
    // Arrange.
    let expectedValues = (Maybe(42), Maybe("hello world"))
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
    let combinedPromise = any(promise1, promise2).then { value in
      XCTAssert(value.0 == expectedValues.0)
      XCTAssert(value.1 == expectedValues.1)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value.0 == expectedValues.0)
    XCTAssert(value.1 == expectedValues.1)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyHeterogeneous2Reject() {
    // Arrange.
    let expectedValuesAndErrors = (Maybe(42), Maybe<String>(Test.Error.code42))
    let promise1 = Promise<Int> { fulfill, _ in
      Test.delay(0.1) {
        fulfill(42)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = any(promise1, promise2).then { number, error in
      XCTAssert(number == expectedValuesAndErrors.0)
      XCTAssert(error == expectedValuesAndErrors.1)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value.0 == expectedValuesAndErrors.0)
    XCTAssert(value.1 == expectedValuesAndErrors.1)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyHeterogeneous2RejectAll() {
    // Arrange.
    let promise1 = Promise<Int> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code13)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = any(promise1, promise2).then { _, _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAnyHeterogeneous2NoDeallocUntilResolved() {
    // Arrange.
    let promise1 = Promise<Int>.pending()
    let promise2 = Promise<String>.pending()
    weak var weakExtendedPromise1: Promise<(Maybe<Int>, Maybe<String>)>?
    weak var weakExtendedPromise2: Promise<(Maybe<Int>, Maybe<String>)>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = any(promise1, promise2)
      weakExtendedPromise2 = any(promise1, promise2)
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

  func testPromiseAnyHeterogeneous3() {
    // Arrange.
    let expectedValues = (Maybe(42), Maybe("hello world"), Maybe(Int?.none))
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
    let combinedPromise = any(promise1, promise2, promise3).then { number, string, none in
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

  func testPromiseAnyHeterogeneous3Reject() {
    // Arrange.
    let expectedValuesAndErrors = (Maybe(42), Maybe<String>(Test.Error.code42), Maybe(Int?.none))
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
    let combinedPromise = any(promise1, promise2, promise3).then { number, error, none in
      XCTAssert(number == expectedValuesAndErrors.0)
      XCTAssert(error == expectedValuesAndErrors.1)
      XCTAssert(none == expectedValuesAndErrors.2)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = combinedPromise.value else { XCTFail(); return }
    XCTAssert(value.0 == expectedValuesAndErrors.0)
    XCTAssert(value.1 == expectedValuesAndErrors.1)
    XCTAssert(value.2 == expectedValuesAndErrors.2)
    XCTAssertNil(combinedPromise.error)
  }

  func testPromiseAnyHeterogeneous3RejectAll() {
    // Arrange.
    let promise1 = Promise<Int> { _, reject in
      Test.delay(0.1) {
        reject(Test.Error.code42)
      }
    }
    let promise2 = Promise<String> { _, reject in
      Test.delay(1) {
        reject(Test.Error.code13)
      }
    }
    let promise3 = Promise<String> { _, reject in
      Test.delay(2) {
        reject(Test.Error.code42)
      }
    }

    // Act.
    let combinedPromise = any(promise1, promise2, promise3).then { _, _, _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(combinedPromise.error == Test.Error.code42)
    XCTAssertNil(combinedPromise.value)
  }

  func testPromiseAnyHeterogeneous3NoDeallocUntilResolved() {
    // Arrange.
    let promise1 = Promise<Int>.pending()
    let promise2 = Promise<String>.pending()
    let promise3 = Promise<Int?>.pending()
    weak var weakExtendedPromise1: Promise<(Maybe<Int>, Maybe<String>, Maybe<Int?>)>?
    weak var weakExtendedPromise2: Promise<(Maybe<Int>, Maybe<String>, Maybe<Int?>)>?

    // Act.
    autoreleasepool {
      XCTAssertNil(weakExtendedPromise1)
      XCTAssertNil(weakExtendedPromise2)
      weakExtendedPromise1 = any(promise1, promise2, promise3)
      weakExtendedPromise2 = any(promise1, promise2, promise3)
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
}
