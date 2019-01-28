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

  /// Waits on a promise for a given interval or rejects the promise if it exceeds the time limit.
  /// - parameters:
  ///   - queue: A queue to dispatch on.
  ///   - interval: Time to wait in seconds.
  /// - returns: A new pending promise that gets either resolved with same resolution as `self` or
  ///            rejected with `PromiseError.timedOut` error.
  @discardableResult
  func timeout(on queue: DispatchQueue = .promises, _ interval: TimeInterval) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, timeout: interval))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__pendingObjects?.add(promise)
    return promise
  }
}
