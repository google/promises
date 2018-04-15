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

class PromiseResolveTests: XCTestCase {
  func testPromiseWrapVoidCompletionFulfillsWithNilValue() {
    // Act.
    let promise = wrap { handler in
      Harness.async(completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertNil(value)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssert(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapObjectCompletionFulfillsOnValueReturned() {
    // Act.
    let promise = wrap { handler in
      Harness.async(value: 42, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = promise.value else { XCTFail(); return }
    XCTAssertEqual(value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapObjectCompletionFulfillsWithNilValue() {
    // Act.
    let promise = wrap { (handler: @escaping (Any?) -> Void) in
      Harness.async(value: nil, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertNil(value)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssert(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapErrorCompletionRejectsOnErrorReturned() {
    // Act.
    let promise = wrap { handler in
      Harness.async(error: Test.Error.code42, completion: handler)
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssert(promise.value == nil)
  }

  func testPromiseWrapErrorCompletionFulfillsWithNilValue() {
    // Act.
    let promise = wrap { handler in
      Harness.async(error: nil, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertNil(value)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssert(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapObjectOrErrorCompletionFulfillsWithNilValue() {
    // Act.
    let promise = wrap { (handler: @escaping (Any?, Error?) -> Void) in
      Harness.async(value: nil, error: nil, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertNil(value)
    }
    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssert(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapErrorOrObjectCompletionFulfillsWithNilValue() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = wrap { (handler: @escaping (Error?, Any?) -> Void) in
      Harness.async(error: nil, value: nil, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertNil(value)
      expectation.fulfill()
    }

    // Assert.
    waitForExpectations(timeout: 10)
    XCTAssertTrue(promise.isFulfilled)
    XCTAssert(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapObjectOrErrorCompletionFulfillsOnValueReturned() {
    // Act.
    let promise = wrap { handler in
      Harness.async(value: 42, error: nil, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let value = promise.value else { XCTFail(); return }
    XCTAssertEqual(value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapErrorOrObjectCompletionFulfillsOnValueReturned() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = wrap { (handler: @escaping (Error?, Int) -> Void) in
      Harness.async(error: nil, value: 42, completion: handler)
    }.catch { _ in
      XCTFail()
    }.then { value in
      XCTAssertEqual(value, 42)
      expectation.fulfill()
    }

    // Assert.
    waitForExpectations(timeout: 10)
    guard let value = promise.value else { XCTFail(); return }
    XCTAssertEqual(value, 42)
    XCTAssertNil(promise.error)
  }

  func testPromiseWrapObjectOrErrorCompletionRejectsOnErrorReturned() {
    // Act.
    let promise = wrap { (handler: @escaping (Any?, Error?) -> Void) in
      Harness.async(value: nil, error: Test.Error.code42, completion: handler)
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssert(promise.value == nil)
  }

  func testPromiseWrapErrorOrObjectCompletionRejectsOnErrorReturned() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = wrap { (handler: @escaping (Error?, Any?) -> Void) in
      Harness.async(error: Test.Error.code42, value: nil, completion: handler)
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
      expectation.fulfill()
    }

    // Assert.
    waitForExpectations(timeout: 10)
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssert(promise.value == nil)
  }

  func testPromiseWrapObjectOrErrorCompletionRejectsOnValueAndErrorReturned() {
    // Act.
    let promise = wrap { (handler: @escaping (Int, Error?) -> Void) in
      Harness.async(value: 42, error: Test.Error.code42, completion: handler)
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

  func testPromiseWrapErrorOrObjectCompletionRejectsOnValueAndErrorReturned() {
    // Arrange.
    let expectation = self.expectation(description: "")

    // Act.
    let promise = wrap { (handler: @escaping (Error?, Int) -> Void) in
      Harness.async(error: Test.Error.code42, value: 42, completion: handler)
    }.then { _ in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
      expectation.fulfill()
    }

    // Assert.
    waitForExpectations(timeout: 10)
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseWrap2ObjectsOrErrorCompletionFulfillsOnValueReturned() {
    // Act.
    let promise = wrap { (handler: @escaping (Int?, String?, Error?) -> Void) in
      Harness.async(value: 42, value: "hello", error: nil, completion: handler)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    guard let (value1, value2) = promise.value else { XCTFail(); return }
    XCTAssert(value1 == 42)
    XCTAssert(value2 == "hello")
    XCTAssertNil(promise.error)
  }

  func testPromiseWrap2ObjectsOrErrorCompletionRejectsOnErrorReturned() {
    // Act.
    let promise = wrap { (handler: @escaping (Int?, String?, Error?) -> Void) in
      Harness.async(
        value: nil, value: nil, error: Test.Error.code42, completion: handler
      )
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  func testPromiseWrap2ObjectsOrErrorCompletionRejectsOnValueAndErrorReturned() {
    // Act.
    let promise = wrap { (handler: @escaping (Int?, Int?, Error?) -> Void) in
      Harness.async(
        value: 42, value: 13, error: Test.Error.code42, completion: handler
      )
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.error == Test.Error.code42)
    XCTAssertNil(promise.value)
  }

  // MARK: - Private

  struct Harness {
    static func async(completion: @escaping () -> Void) {
      Test.delay(0.1) {
        completion()
      }
    }

    static func async<Value>(value: Value, completion: @escaping (Value) -> Void) {
      Test.delay(0.1) {
        completion(value)
      }
    }

    static func async<Value>(value: Value?, completion: @escaping (Value?) -> Void) {
      Test.delay(0.1) {
        completion(value)
      }
    }

    static func async(error: Error?, completion: @escaping (Error?) -> Void) {
      Test.delay(0.1) {
        completion(error)
      }
    }

    static func async<Value>(
      value: Value,
      error: Error?,
      completion: @escaping (Value, Error?) -> Void
    ) {
      Test.delay(0.1) {
        completion(value, error)
      }
    }

    static func async<Value>(
      error: Error?,
      value: Value,
      completion: @escaping (Error?, Value) -> Void
    ) {
      Test.delay(0.1) {
        completion(error, value)
      }
    }

    static func async<Value>(
      value: Value?,
      error: Error?,
      completion: @escaping (Value?, Error?) -> Void
    ) {
      Test.delay(0.1) {
        completion(value, error)
      }
    }

    static func async<Value>(
      error: Error?,
      value: Value?,
      completion: @escaping (Error?, Value?) -> Void
    ) {
      Test.delay(0.1) {
        completion(error, value)
      }
    }

    static func async<Value1, Value2>(
      value value1: Value1?,
      value value2: Value2?,
      error: Error?,
      completion: @escaping (Value1?, Value2?, Error?) -> Void
    ) {
      Test.delay(0.1) {
        completion(value1, value2, error)
      }
    }
  }
}
