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

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with an array
/// of values or `Error`s, matching the original order of fulfilled or rejected promises
/// respectively.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of array containing the values or `Error`s of input promises in their
///            original order.
public func when<Value>(
  on queue: DispatchQueue = .main,
  _ promises: Promise<Value>...
) -> Promise<[Value]> {
  return when(on: queue, promises)
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with an array
/// of values or `Error`s, matching the original order of fulfilled or rejected promises
/// respectively.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of array containing the values or `Error`s of input promises in their
///            original order.
public func when<Value, Container: Sequence>(
  on queue: DispatchQueue = .main,
  _ promises: Container
) -> Promise<[Value]> where Container.Iterator.Element == Promise<Value> {
  let promise = Promise<[Value]>(
    Promise<[Value]>.ObjCPromise<AnyObject>.__onQueue(queue, when: promises.map { $0.objCPromise })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.objCPromise.__pendingObjects?.add(promise)
  }
  return promise
}
