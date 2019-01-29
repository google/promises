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

import Dispatch

public extension Promise {
  typealias Reducer<Element> = (Value, Element) throws -> Promise<Value>

  /// Sequentially reduces a collection of values to a single promise using a given combining block
  /// and the value `self` resolves with as initial value.
  /// - parameters:
  ///   - queue: A queue to execute `reducer` block on.
  ///   - items: A sequence of values to process in order.
  ///   - reducer: A block to combine an accumulating value and an element of the sequence into
  ///              a promise resolved with the new accumulating value, to be used in the next call
  ///              of the `reducer` or returned to the caller.
  /// - returns: A new pending promise returned from the last `reducer` invocation.
  ///            Or `self` if `items` is empty.
  @discardableResult
  func reduce<Element>(
    on queue: DispatchQueue = .promises,
    _ items: Element...,
    combine reducer: @escaping Reducer<Element>
  ) -> Promise<Value> {
    return reduce(on: queue, items, reducer)
  }

  /// Sequentially reduces a collection of values to a single promise using a given combining block
  /// and the value `self` resolves with as initial value.
  /// - parameters:
  ///   - queue: A queue to execute `reducer` block on.
  ///   - items: A sequence of values to process in order.
  ///   - reducer: A block to combine an accumulating value and an element of the sequence into
  ///              a promise resolved with the new accumulating value, to be used in the next call
  ///              of the `reducer` or returned to the caller.
  /// - returns: A new pending promise returned from the last `reducer` invocation.
  ///            Or `self` if `items` is empty.
  @discardableResult
  func reduce<Container: Sequence>(
    on queue: DispatchQueue = .promises,
    _ items: Container,
    _ reducer: @escaping Reducer<Container.Element>
  ) -> Promise<Value> {
    return items.reduce(self) { promise, item in
      promise.then { value in
        try reducer(value, item)
      }
    }
  }
}
