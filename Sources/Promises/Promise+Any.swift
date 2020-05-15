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
/// of `Maybe` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array of `Maybe` enums containing the values or `Error`s of input
///            promises in their original order.
public func any<Value>(
  on queue: DispatchQueue = .promises,
  _ promises: Promise<Value>...
) -> Promise<[Maybe<Value>]> {
  return any(on: queue, promises)
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with an array
/// of `Maybe` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array of `Maybe` enums containing the values or `Error`s of input
///            promises in their original order.
public func any<Value, Container: Sequence>(
  on queue: DispatchQueue = .promises,
  _ promises: Container
) -> Promise<[Maybe<Value>]> where Container.Element == Promise<Value> {
  let promises = promises.map { $0.objCPromise }
  let promise = Promise<[Maybe<Value>]>(
    Promise<[Maybe<Value>]>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      any: promises
    ).__onQueue(queue, then: { values in
      guard let values = values as [AnyObject]? else { preconditionFailure() }
      return Promise<[Maybe<Value>]>.asAnyObject(values.map { asMaybe($0) as Maybe<Value> })
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__addPendingObject(promise)
  }
  return promise
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with a tuple
/// of `Maybe` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
/// - returns: Promise of a tuple of `Maybe` enums containing the values or `Error`s of input
///            promises in their original order.
public func any<A, B>(
  on queue: DispatchQueue = .promises,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>
) -> Promise<(Maybe<A>, Maybe<B>)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise
  ]
  let promise = Promise<(Maybe<A>, Maybe<B>)>(
    Promise<(Maybe<A>, Maybe<B>)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      any: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]? else { preconditionFailure() }
      let valueA = asMaybe(values[0]) as Maybe<A>
      let valueB = asMaybe(values[1]) as Maybe<B>
      return (valueA, valueB)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__addPendingObject(promise)
  }
  return promise
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with a tuple
/// of `Maybe` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
///   - promiseC: Promise of type `C`.
/// - returns: Promise of a tuple of `Maybe` enums containing the values or `Error`s of input
///            promises in their original order.
public func any<A, B, C>(
  on queue: DispatchQueue = .promises,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>,
  _ promiseC: Promise<C>
) -> Promise<(Maybe<A>, Maybe<B>, Maybe<C>)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise,
    promiseC.objCPromise
  ]
  let promise = Promise<(Maybe<A>, Maybe<B>, Maybe<C>)>(
    Promise<(Maybe<A>, Maybe<B>, Maybe<C>)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      any: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]? else { preconditionFailure() }
      let valueA = asMaybe(values[0]) as Maybe<A>
      let valueB = asMaybe(values[1]) as Maybe<B>
      let valueC = asMaybe(values[2]) as Maybe<C>
      return (valueA, valueB, valueC)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__addPendingObject(promise)
  }
  return promise
}

/// Wrapper enum for `any` results.
/// - value: Contains the value that corresponding promise was fulfilled with.
/// - error: Contains the error that corresponding promise was rejected with.
public enum Maybe<Value> {
  case value(Value)
  case error(Error)

  public init(_ value: Value) { self = .value(value) }

  public init(_ error: Error) { self = .error(error) }

  public var value: Value? {
    if case .value(let value) = self { return value } else { return nil }
  }

  public var error: Error? {
    if case .error(let error) = self { return error } else { return nil }
  }
}

// MARK: - Conversion

/// Helper functions that facilitates conversion of `Promise.any` results to the results normally
/// expected from `ObjCPromise.any`.
///
/// Convert a promise created with `any` in Swift to Objective-C:
///
/// any([promise1, promise2, promise3]).then { arrayOfMaybeEnums in
///   return arrayOfMaybeEnums.map { $0.asAnyObject() }
/// }.asObjCPromise() as Promise<[AnyObject?]>.ObjCPromise<AnyObject>
///
/// Convert a promise created with `any` in Objective-C to Swift:
///
/// Promise<[AnyObject]>(objCPromise).then { arrayOfAnyObjects in
///   return arrayOfAnyObjects.map { asMaybe($0) as Maybe<SomeValue> }
/// }
public extension Maybe {

  /// Converts generic `Value` to `AnyObject`.
  func asAnyObject() -> AnyObject? {
    switch self {
    case .value(let value):
      return Promise<Value>.asAnyObject(value)
    case .error(let error):
      return error as NSError
    }
  }
}

/// Helper function to wrap the results of `ObjCPromise.any` with the safe `Maybe` enum.
public func asMaybe<Value>(_ value: AnyObject) -> Maybe<Value> {
  switch value {
  case let error as NSError:
    return .error(error)
  case let value:
    guard let value = Promise<Value>.asValue(value) else { preconditionFailure() }
    return .value(value)
  }
}

// MARK: - Equatable

/// Equality operators for `Maybe`.
#if !swift(>=4.1)
extension Maybe where Value: Equatable {}
#else
extension Maybe: Equatable where Value: Equatable {}
#endif  // !swift(>=4.1)

public func == <Value: Equatable>(lhs: Maybe<Value>, rhs: Maybe<Value>) -> Bool {
  switch (lhs, rhs) {
  case (.value(let lhs), .value(let rhs)):
    return lhs == rhs
  case (.error(let lhs), .error(let rhs)):
    return (lhs as NSError).isEqual(rhs as NSError)
  case (.value, .error), (.error, .value):
    return false
  }
}

public func != <Value: Equatable>(lhs: Maybe<Value>, rhs: Maybe<Value>) -> Bool {
  return !(lhs == rhs)
}

#if !swift(>=4.1)

public func == <Value: Equatable>(lhs: Maybe<Value?>, rhs: Maybe<Value?>) -> Bool {
  switch (lhs, rhs) {
  case (.value(let lhs), .value(let rhs)):
    switch (lhs, rhs) {
    case (nil, nil):
      return true
    case (nil, _?), (_?, nil):
      return false
    case let (lhs?, rhs?):
      return lhs == rhs
    }
  case (.error(let lhs), .error(let rhs)):
    return (lhs as NSError).isEqual(rhs as NSError)
  case (.value, .error), (.error, .value):
    return false
  }
}

public func != <Value: Equatable>(lhs: Maybe<Value?>, rhs: Maybe<Value?>) -> Bool {
  return !(lhs == rhs)
}

public func == <Value: Equatable>(lhs: [Maybe<Value>], rhs: [Maybe<Value>]) -> Bool {
  if lhs.count != rhs.count { return false }
  for (lhs, rhs) in zip(lhs, rhs) where lhs != rhs { return false }
  return true
}

public func != <Value: Equatable>(lhs: [Maybe<Value>], rhs: [Maybe<Value>]) -> Bool {
  return !(lhs == rhs)
}

public func == <Value: Equatable>(lhs: [Maybe<Value?>], rhs: [Maybe<Value?>]) -> Bool {
  if lhs.count != rhs.count { return false }
  for (lhs, rhs) in zip(lhs, rhs) where lhs != rhs { return false }
  return true
}

public func != <Value: Equatable>(lhs: [Maybe<Value?>], rhs: [Maybe<Value?>]) -> Bool {
  return !(lhs == rhs)
}

#endif  // !swift(>=4.1)
