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

/// Wait until any of the given promises are fulfilled.
/// If one of the given promises is rejected, then the returned promise is rejected with same
/// error. If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: First promise, among the given ones, which was fulfilled.
public func race<Value>(
  on queue: DispatchQueue = .promises,
  _ promises: Promise<Value>...
) -> Promise<Value> {
  return race(on: queue, promises)
}

/// Wait until any of the given promises are fulfilled.
/// If one of the given promises is rejected, then the returned promise is rejected with same
/// error. If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: First promise, among the given ones, which was fulfilled.
public func race<Value>(
  on queue: DispatchQueue = .promises,
  _ promises: [Promise<Value>]
) -> Promise<Value> {
  let promises = promises.map { $0.objCPromise }
  let promise = Promise<Value>(
    Promise<Value>.ObjCPromise<AnyObject>.__onQueue(queue, race: promises)
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__addPendingObject(promise)
  }
  return promise
}
