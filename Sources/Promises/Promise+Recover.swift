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

  /// Provides a new promise to recover in case `self` gets rejected.
  /// - parameters:
  ///   - queue: A queue to execute `recovery` block on.
  ///   - recovery: A block to handle the error that `self` was rejected with.
  /// - returns: A new pending promise to use instead of the rejected one that gets resolved with
  ///            the same resolution as the promise returned from `recovery` block.
  @discardableResult
  func recover(
    on queue: DispatchQueue = .promises,
    _ recovery: @escaping (Error) throws -> Promise
  ) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, recover: {
      do {
        // Convert `NSError` to `PromiseError`, if applicable.
        let error = PromiseError($0) ?? $0
        return try recovery(error).objCPromise
      } catch let error {
        return error as NSError
      }
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }

  /// Provides a new promise to recover in case `self` gets rejected.
  /// - parameters:
  ///   - queue: A queue to execute `recovery` block on.
  ///   - recovery: A block to handle the error that `self` was rejected with.
  /// - returns: A new pending promise to use instead of the rejected one that gets resolved with
  ///            the value returned from `recovery` block.
  @discardableResult
  func recover(
    on queue: DispatchQueue = .promises,
    _ recovery: @escaping (Error) throws -> Value
  ) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, recover: {
      do {
        // Convert `NSError` to `PromiseError`, if applicable.
        let error = PromiseError($0) ?? $0
        return Promise<Value>.asAnyObject(try recovery(error)) as Any
      } catch let error {
        return error as NSError
      }
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }
}
