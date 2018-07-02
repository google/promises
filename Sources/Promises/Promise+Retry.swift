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

import FBLPromises

/// Creates a pending promise that fulfills with the same value as the promise returned from `work`
/// block, which executes asynchronously on the given `queue`, or rejects with the same error after
/// all retry attempts have been exhausted. On rejection, the `work` block is reattempted after the
/// given `delay` and will continue to retry until the number of specified `attempts` have been
/// exhausted or will bail early if the given `condition` is not met.
///
/// - parameters:
///   - queue: A queue to invoke the `work` block on.
///   - count: Max number of retry attempts.
///   - interval: Time to wait before the next retry attempt.
///   - predicate: Condition to check before the next retry attempt.
///     - count: Number of remaining retry attempts.
///     - error: The error the promise was rejected with.
///   - work: A block that executes asynchronously on the given `queue` and returns a value or an
///           error used to resolve the promise.
/// - returns: A new pending promise that fulfills with the same value as the promise returned from
///            `work` block, or rejects with the same error after all retry attempts have been
///            exhausted or if the given `condition` is not met.
public func retry<Value>(
  on queue: DispatchQueue = .promises,
  attempts count: Int = __FBLPromiseRetryDefaultAttempts,
  delay interval: TimeInterval = __FBLPromiseRetryDefaultDelay,
  condition predicate: ((_ count: Int, _ error: Error) -> Bool)? = nil,
  _ work: @escaping () throws -> Promise<Value>
) -> Promise<Value> {
  let objCPromise = Promise<Value>.ObjCPromise<AnyObject>.__onQueue(
    queue,
    attempts: count,
    delay: interval,
    condition: predicate
  ) {
    do {
      return try work().objCPromise
    } catch let error {
      return error as NSError
    }
  }
  let promise = Promise<Value>(objCPromise)
  // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
  objCPromise.__pendingObjects?.add(promise)
  return promise
}
