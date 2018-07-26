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

/// Waits until all of the promises have been fulfilled.
/// If one of the promises is rejected, then the returned promise is rejected with same error.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array containing the values of input promises in the same order.
public func all<Value>(
  on queue: DispatchQueue = .promises,
  _ promises: Promise<Value>...
) -> Promise<[Value]> {
  return all(on: queue, promises)
}

/// Waits until all of the promises have been fulfilled.
/// If one of the promises is rejected, then the returned promise is rejected with same error.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array containing the values of input promises in the same order.
public func all<Value, Container: Sequence>(
  on queue: DispatchQueue = .promises,
  _ promises: Container
) -> Promise<[Value]> where Container.Element == Promise<Value> {
  let promises = promises.map { $0.objCPromise }
  let promise = Promise<[Value]>(
    Promise<[Value]>.ObjCPromise<AnyObject>.__onQueue(queue, all: promises)
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Waits until all of the promises have been fulfilled.
/// If one of the promises is rejected, then the returned promise is rejected with same error.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
/// - returns: Promise of a tuple containing the values of input promises in the same order.
public func all<A, B>(
  on queue: DispatchQueue = .promises,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>
) -> Promise<(A, B)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise
  ]
  let promise = Promise<(A, B)>(
    Promise<(A, B)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      all: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]?,
            let valueA = Promise<A>.asValue(values[0]),
            let valueB = Promise<B>.asValue(values[1])
      else {
        preconditionFailure("Cannot convert \(type(of: objCValues)) to \((A, B).self)")
      }
      return (valueA, valueB)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Waits until all of the promises have been fulfilled.
/// If one of the promises is rejected, then the returned promise is rejected with same error.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
///   - promiseC: Promise of type `C`.
/// - returns: Promise of a tuple containing the values of input promises in the same order.
public func all<A, B, C>(
  on queue: DispatchQueue = .promises,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>,
  _ promiseC: Promise<C>
) -> Promise<(A, B, C)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise,
    promiseC.objCPromise
  ]
  let promise = Promise<(A, B, C)>(
    Promise<(A, B, C)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      all: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]?,
            let valueA = Promise<A>.asValue(values[0]),
            let valueB = Promise<B>.asValue(values[1]),
            let valueC = Promise<C>.asValue(values[2])
      else {
        preconditionFailure("Cannot convert \(type(of: objCValues)) to \((A, B, C).self)")
      }
      return (valueA, valueB, valueC)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Waits until all of the promises have been fulfilled.
/// If one of the promises is rejected, then the returned promise is rejected with same error.
/// If any other arbitrary value or `Error` appears in the array instead of `Promise`,
/// it's implicitly considered a pre-fulfilled or pre-rejected `Promise` correspondingly.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
///   - promiseC: Promise of type `C`.
///   - promiseD: Promise of type `D`.
/// - returns: Promise of a tuple containing the values of input promises in the same order.
public func all<A, B, C, D>(
  on queue: DispatchQueue = .promises,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>,
  _ promiseC: Promise<C>,
  _ promiseD: Promise<D>
) -> Promise<(A, B, C, D)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise,
    promiseC.objCPromise,
    promiseD.objCPromise
  ]
  let promise = Promise<(A, B, C, D)>(
    Promise<(A, B, C, D)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      all: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]?,
            let valueA = Promise<A>.asValue(values[0]),
            let valueB = Promise<B>.asValue(values[1]),
            let valueC = Promise<C>.asValue(values[2]),
            let valueD = Promise<D>.asValue(values[3])
      else {
        preconditionFailure("Cannot convert \(type(of: objCValues)) to \((A, B, C, D).self)")
      }
      return (valueA, valueB, valueC, valueD)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

