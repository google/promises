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

class PromiseProgressTests: XCTestCase {
  func testPromiseProgressCancel() {
    // Arrange.
    let promise = Promise<(Data?, URLResponse?)>(progressUnits: 10) { fulfill, reject, progress in
      let task = URLSession.shared.dataTask(
        with:URL(string: "https://google.com")!
      ) { data, response, error in
        if let error = error {
          reject(error)
        } else {
          fulfill((data, response))
        }
      }
      if #available(iOS 11.0, *) {
        progress.addChild(task.progress, withPendingUnitCount: progress.totalUnitCount)
      } else {
        // Fallback on earlier versions
      }
      task.resume()
    }.then { value, progress in
      progress.completedUnitCount += 5
    }

    // Act.
    Test.delay(5) {
      promise.cancel()
    }

    // Assert.
    XCTAssert(waitForPromises(timeout: 10))
    print(promise)
  }
}
