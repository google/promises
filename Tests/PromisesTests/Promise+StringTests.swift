// Copyright 2022 Google Inc. All rights reserved.
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

/// This extension exists to ensure that String Promises correctly identify errors even
/// when a String can be cast to Error. This same concept could be applied to other types;
/// String was chosen for these tests as it was the first to manifest issues related to
/// Error extensions.
extension String: Error {}

class PromiseStringTests: XCTestCase {

  func testPromiseStringFufill() {
    func work1(_ value: String) -> Promise<String> {
      return Promise { value }
    }
    func work2(_ value: String) -> Promise<String> {
      return Promise { value }
    }
    let promise1 = work1("42")
    let promise2 = promise1.then(work2)

    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(promise2.value, "42")
    XCTAssertNil(promise2.error)
    
    XCTAssertEqual(promise1.value, "42")
    XCTAssertNil(promise1.error)
  }
  
  func testPromiseStringReject() {
    func work1(_ value: String) -> Promise<String> {
      return Promise<String> { (fufill, _) in
        fufill(value)
      }
    }
    func work2(_ value: String) -> Promise<String> {
      return Promise<String> { (_, reject) in
        reject(Test.Error.code42)
      }
    }
    
    let promise1 = work1("42")
    let promise2 = promise1.then(work2)

    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertTrue(promise2.error == Test.Error.code42)
    XCTAssertNil(promise2.value)
    
    XCTAssertEqual(promise1.value, "42")
    XCTAssertNil(promise1.error)
  }

  func testPromiseVec2() {
    /// A 2D vector.
    struct Vec2 {
      let x: String, y: String
    }
    func work1(_ value: Vec2) -> Promise<Vec2> {
      return Promise { value }
    }
    func work2(_ value: Vec2) -> Promise<Vec2> {
      return Promise { value }
    }
    let promise1 = work1(Vec2(x: "42", y: "43"))
    let promise2 = promise1.then(work2)

    XCTAssert(waitForPromises(timeout: 3))
    XCTAssertEqual(promise2.value?.x, "42")
    XCTAssertEqual(promise1.value?.x, "42")
  }
}
