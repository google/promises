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

class PromiseThenPerformanceTests: XCTestCase {

  // MARK: GCD

  /// Measures the average time needed to get into a dispatch_async block.
  func testDispatchAsyncOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        queue.async {
          semaphore.signal()
          expectation.fulfill()
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the average time needed to get into a doubly nested dispatch_async block.
  func testDoubleDispatchAsyncOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        queue.async {
          queue.async {
            semaphore.signal()
            expectation.fulfill()
          }
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the average time needed to get into a triply nested dispatch_async block.
  func testTripleDispatchAsyncOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        queue.async {
          queue.async {
            queue.async {
              semaphore.signal()
              expectation.fulfill()
            }
          }
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the total time needed to perform a lot of `DispatchQueue.async` blocks on
  /// a concurrent queue.
  func testDispatchAsyncOnConcurrentQueue() {
    // Arrange.
    let queue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
    let group = DispatchGroup()
    var blocks = [() -> Void]()
    for _ in 0..<Constants.iterationCount {
      group.enter()
      blocks.append({
        group.leave()
      })
    }
    let startDate = Date()

    // Act.
    for block in blocks {
      queue.async {
        block()
      }
    }

    // Assert.
    XCTAssert(group.wait(timeout: .now() + 1) == .success)
    let endDate = Date()
    print(total: endDate.timeIntervalSince(startDate))
  }

  // MARK: Promises

  /// Measures the average time needed to create a resolved `Promise` and get into a `then` block
  /// chained to it.
  func testThenOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        Promise<Bool>(true).then(on: queue) { _ in
          semaphore.signal()
          expectation.fulfill()
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the average time needed to create a resolved `Promise`, chain two `then` blocks on
  /// it and get into the last `then` block.
  func testDoubleThenOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        Promise<Bool>(true).then(on: queue) { _ in
        }.then(on: queue) { _ in
          semaphore.signal()
          expectation.fulfill()
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the average time needed to create a resolved `Promise`, chain three `then` blocks on
  /// it and get into the last `then` block.
  func testTripleThenOnSerialQueue() {
    // Arrange.
    let expectation = self.expectation(description: "")
    expectation.expectedFulfillmentCount = Constants.iterationCount
    let queue = DispatchQueue(label: #function, qos: .userInitiated)
    let semaphore = DispatchSemaphore(value: 0)

    // Act.
    DispatchQueue.main.async {
      let time = dispatch_benchmark(Constants.iterationCount) {
        Promise<Bool>(true).then(on: queue) { _ in
        }.then(on: queue) { _ in
        }.then(on: queue) { _ in
          semaphore.signal()
          expectation.fulfill()
        }
        semaphore.wait()
      }
      print(average: time)
    }

    // Assert.
    waitForExpectations(timeout: 10)
  }

  /// Measures the total time needed to resolve a lot of pending `Promise` with chained `then`
  /// blocks on them on a concurrent queue and wait for each of them to get into chained block.
  func testThenOnConcurrentQueue() {
    // Arrange.
    let queue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
    let group = DispatchGroup()
    var promises = [Promise<Bool>]()
    for _ in 0..<Constants.iterationCount {
      group.enter()
      let promise = Promise<Bool>.pending()
      promise.then(on: queue) { _ in
        group.leave()
      }
      promises.append(promise)
    }
    let startDate = Date()

    // Act.
    for promise in promises {
      promise.fulfill(true)
    }

    // Assert.
    XCTAssert(group.wait(timeout: .now() + 1) == .success)
    let endDate = Date()
    print(total: endDate.timeIntervalSince(startDate))
  }
}

// MARK: - Constants

struct Constants {
  static let iterationCount = 10_000
}

// MARK: - Helpers

func print(average time: UInt64) {
  print(String(format: "Average time: %.10lf", Double(time) / Double(NSEC_PER_SEC)))
}

func print(total time: TimeInterval) {
  print(String(format: "Total time: %.10lf", time))
}
