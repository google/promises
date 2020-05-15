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

import Foundation

public extension Promise {
  typealias Then<Result> = (Value) throws -> Result

  /// Creates a pending promise which eventually gets resolved with the same resolution as the
  /// promise returned from `work` block. The `work` block is executed asynchronously on the given
  /// `queue` only when `self` is fulfilled. If `self` is rejected, the returned promise is also
  /// rejected with the same error.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work:  A block to handle the value that `self` was fulfilled with.
  /// - returns: A new pending promise to be resolved with the same resolution as the promise
  ///            returned from the `work` block.
  @discardableResult
  func then<Result>(
    on queue: DispatchQueue = .promises,
    _ work: @escaping Then<Promise<Result>>
  ) -> Promise<Result> {
    let promise = Promise<Result>(objCPromise.__onQueue(queue, then: { objCValue in
      guard let value = Promise<Value>.asValue(objCValue) else {
        preconditionFailure("Cannot cast \(type(of: objCValue)) to \(Value.self)")
      }
      do {
        return try work(value).objCPromise
      } catch let error {
        return error as NSError
      }
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }

  /// Creates a pending promise which eventually gets resolved with the value returned from `work`
  /// block. The `work` block is executed asynchronously on the given `queue` only when `self` is
  /// fulfilled. If `self` is rejected, the returned promise is also rejected with the same error.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work:  A block to handle the value that `self` was fulfilled with.
  /// - returns: A new pending promise to be resolved with the value returned from the `work` block.
  @discardableResult
  func then<Result>(
    on queue: DispatchQueue = .promises,
    _ work: @escaping Then<Result>
  ) -> Promise<Result> {
    let promise = Promise<Result>(objCPromise.__onQueue(queue, then: { objCValue in
      guard let value = Promise<Value>.asValue(objCValue) else {
        preconditionFailure("Cannot cast \(type(of: objCValue)) to \(Value.self)")
      }
      do {
        let value = try work(value)
        return value as? NSError ?? Promise<Result>.asAnyObject(value)
      } catch let error {
        return error as NSError
      }
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }

  /// Creates a pending promise which eventually gets resolved with the same resolution as `self`.
  /// `work` block is executed asynchronously on the given `queue` only when `self` is fulfilled.
  /// If `self` is rejected, the returned promise is also rejected with the same error.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work:  A block to handle the value that `self` was fulfilled with.
  /// - returns: A new pending promise to be resolved with the value passed into the `work` block.
  @discardableResult
  func then(
    on queue: DispatchQueue = .promises,
    _ work: @escaping Then<Void>
  ) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, then: { objCValue in
      guard let value = Promise<Value>.asValue(objCValue) else {
        preconditionFailure("Cannot cast \(type(of: objCValue)) to \(Value.self)")
      }
      do {
        try work(value)
        return Promise<Value>.asAnyObject(value)
      } catch let error {
        return error as NSError
      }
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }
}
