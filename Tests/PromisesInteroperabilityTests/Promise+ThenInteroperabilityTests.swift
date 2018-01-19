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

import FBLPromisesTestHelpers
import PromisesTestHelpers
import XCTest
@testable import Promises

class PromiseThenInteroperabilityTests: XCTestCase {
  func testPromiseFulfillOptionalNumberNil() {
    // Act.
    let promise = Promise<Int?>(
      FBLPromisesTestInteroperabilityObjC<NSNumber>.fulfill(nil, delay: 0.1)
    )
    promise.then { (number: Int?) -> Promise<Int?> in
      XCTAssertNil(number)
      return Promise<Int?>(FBLPromisesTestInteroperabilityObjC<NSNumber>.fulfill(nil, delay: 0.1))
    }.then { (number: Int?) -> Int? in
      XCTAssertNil(number)
      return nil
    }.then { number in
      XCTAssertNil(number)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssertTrue(promise.value == nil)
    XCTAssertNil(promise.error)
  }

  func testPromiseFulfillOptionalNumberNonNil() {
    // Act.
    let promise = Promise<Int?>(
      FBLPromisesTestInteroperabilityObjC<NSNumber>.fulfill(42, delay: 0.1)
    )
    promise.then { (number: Int?) -> Promise<Int?> in
      XCTAssertEqual(number, 42)
      return Promise<Int?>(FBLPromisesTestInteroperabilityObjC<NSNumber>.fulfill(42, delay: 0.1))
    }.then { (number: Int?) -> Int? in
      XCTAssertEqual(number, 42)
      return 42
    }.then { number in
      XCTAssertEqual(number, 42)
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise.isFulfilled)
    XCTAssertEqual(promise.value ?? 0, 42)
    XCTAssertNil(promise.error)
  }
}
