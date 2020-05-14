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

  /// Provides a way to always execute a given chained block.
  /// - parameters:
  ///   - queue: A queue to dispatch on.
  ///   - work: A block that always executes, no matter if `self` is rejected or fulfilled.
  /// - returns: A new pending promise to be resolved with same resolution as `self`.
  @discardableResult
  func always(on queue: DispatchQueue = .promises, _ work: @escaping () -> Void) -> Promise {
    let promise = Promise(objCPromise.__onQueue(queue, always: work))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(promise)
    return promise
  }
}
