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

class PromiseReduceTests: XCTestCase {
  func testPromiseReduce() {
    // Arrange.
    let numbers = [1, 2, 3]
    var count = 0

    // Act.
    Promise("").reduce(numbers) { partialString, nextNumber in
      count += 1
      return Promise { fulfill, _ in
        Test.delay(0.1) {
          fulfill(partialString + String(nextNumber))
        }
      }
    }.then { string in
      XCTAssertEqual(string, numbers.map(String.init).reduce("", +))
      count += 1
    }.catch { _ in
      XCTFail()
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, numbers.count + 1)
  }

  func testPromiseReduceThrow() {
    // Arrange.
    var count = 0

    // Act.
    Promise("").reduce(1, 2, 3) { partialString, nextNumber in
      guard partialString.isEmpty else { throw Test.Error.code42 }
      count += 1
      return Promise(partialString + String(nextNumber))
    }.then { string in
      XCTFail()
    }.catch { error in
      XCTAssertTrue(error == Test.Error.code42)
      count += 1
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    XCTAssertEqual(count, 2)
  }
}
