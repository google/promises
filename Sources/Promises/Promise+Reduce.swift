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

  @discardableResult
  public func reduce<Element>(
    on queue: DispatchQueue = .promises,
    _ items: Element...,
    combine reducer: @escaping (Value, Element) throws -> Promise<Value>
  ) -> Promise<Value> {
    return reduce(on: queue, items, reducer)
  }

  @discardableResult
  public func reduce<Container: Sequence>(
    on queue: DispatchQueue = .promises,
    _ items: Container,
    _ reducer: @escaping (Value, Container.Element) throws -> Promise<Value>
  ) -> Promise<Value> {
    return items.reduce(self) { promise, item in
      promise.then { value in
        try reducer(value, item)
      }
    }
  }
}
