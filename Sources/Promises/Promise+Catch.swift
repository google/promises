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
  public typealias Catch = (Error) -> Void

  /// Creates a pending promise which eventually gets resolved with same resolution as `self`.
  /// If `self` is rejected, then `reject` block is executed asynchronously on the given queue.
  /// - parameters:
  ///   - queue: A queue to invoke the `reject` block on.
  ///   - reject: A block to handle the error that `self` was rejected with.
  /// - returns: A new pending promise.
  @discardableResult
  public func `catch`(on queue: DispatchQueue = .promises, _ reject: @escaping Catch) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, catch: {
      // Convert `NSError` to `PromiseError`, if applicable.
      let error = PromiseError($0) ?? $0
      return reject(error as NSError)
    }))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__pendingObjects?.add(promise)
    return promise
  }
}
