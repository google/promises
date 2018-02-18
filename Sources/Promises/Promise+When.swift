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
/// of `When` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array of `When` enums containing the values or `Error`s of input
///            promises in their original order.
public func when<Value>(
  on queue: DispatchQueue = .main,
  _ promises: Promise<Value>...
) -> Promise<[When<Value>]> {
  return when(on: queue, promises)
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with an array
/// of `When` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promises: Promises to wait for.
/// - returns: Promise of an array of `When` enums containing the values or `Error`s of input
///            promises in their original order.
public func when<Value, Container: Sequence>(
  on queue: DispatchQueue = .main,
  _ promises: Container
) -> Promise<[When<Value>]> where Container.Iterator.Element == Promise<Value> {
  let promises = promises.map { $0.objCPromise }
  let promise = Promise<[When<Value>]>(
    Promise<[When<Value>]>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      when: promises
    ).__onQueue(queue, then: { values in
      guard let values = values as [AnyObject]? else { preconditionFailure() }
      return Promise<[When<Value>]>.asAnyObject(values.map { asWhen($0) as When<Value> })
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with a tuple
/// of `When` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
/// - returns: Promise of a tuple of `When` enums containing the values or `Error`s of input
///            promises in their original order.
public func when<A, B>(
  on queue: DispatchQueue = .main,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>
) -> Promise<(When<A>, When<B>)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise
  ]
  let promise = Promise<(When<A>, When<B>)>(
    Promise<(When<A>, When<B>)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      when: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]? else { preconditionFailure() }
      let valueA = asWhen(values[0]) as When<A>
      let valueB = asWhen(values[1]) as When<B>
      return (valueA, valueB)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Waits for all of the given promises to be fulfilled or rejected.
/// If all promises are rejected, then the returned promise is rejected with same error
/// as the last one rejected.
/// If at least one of the promises is fulfilled, the resulting promise is fulfilled with a tuple
/// of `When` enums containing values or `Error`s, matching the original order of fulfilled or
/// rejected promises respectively.
/// - parameters:
///   - queue: A queue to dispatch on.
///   - promiseA: Promise of type `A`.
///   - promiseB: Promise of type `B`.
///   - promiseC: Promise of type `C`.
/// - returns: Promise of a tuple of `When` enums containing the values or `Error`s of input
///            promises in their original order.
public func when<A, B, C>(
  on queue: DispatchQueue = .main,
  _ promiseA: Promise<A>,
  _ promiseB: Promise<B>,
  _ promiseC: Promise<C>
) -> Promise<(When<A>, When<B>, When<C>)> {
  let promises = [
    promiseA.objCPromise,
    promiseB.objCPromise,
    promiseC.objCPromise
  ]
  let promise = Promise<(When<A>, When<B>, When<C>)>(
    Promise<(When<A>, When<B>, When<C>)>.ObjCPromise<AnyObject>.__onQueue(
      queue,
      when: promises
    ).__onQueue(queue, then: { objCValues in
      guard let values = objCValues as [AnyObject]? else { preconditionFailure() }
      let valueA = asWhen(values[0]) as When<A>
      let valueB = asWhen(values[1]) as When<B>
      let valueC = asWhen(values[2]) as When<C>
      return (valueA, valueB, valueC)
    })
  )
  // Keep Swift wrapper alive for chained promises until `ObjCPromise` counterpart is resolved.
  promises.forEach {
    $0.__pendingObjects?.add(promise)
  }
  return promise
}

/// Wrapper enum for `when` results.
/// - value: Contains the value that corresponding promise was fulfilled with.
/// - error: Contains the error that corresponding promise was rejected with.
public enum When<Value> {
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

/// Helper functions that facilitates conversion of `Promise.when` results to the results normally
/// expected from `ObjCPromise.when`.
///
/// Convert a promise created with `when` in Swift to Objective-C:
///
/// when([promise1, promise2, promise3]).then { arrayOfWhenEnums in
///   return arrayOfWhenEnums.map { $0.asAnyObject() }
/// }.asObjCPromise() as Promise<[AnyObject?]>.ObjCPromise<AnyObject>
///
/// Convert a promise created with `when` in Objective-C to Swift:
///
/// Promise<[AnyObject]>(objCPromise).then { arrayOfAnyObjects in
///   return arrayOfAnyObjects.map { asWhen($0) as When<SomeValue> }
/// }
public extension When {

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

/// Equality operators for `When`.
public extension When where Value: Equatable {
  static func == (lhs: When<Value>, rhs: When<Value>) -> Bool {
    switch (lhs, rhs) {
    case (.value(let lhs), .value(let rhs)):
      return lhs == rhs
    case (.error(let lhs), .error(let rhs)):
      return (lhs as NSError).isEqual(rhs as NSError)
    case (.value, .error), (.error, .value):
      return false
    }
  }

  static func == (lhs: When<Value?>, rhs: When<Value?>) -> Bool {
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

  static func != (lhs: When<Value>, rhs: When<Value>) -> Bool {
    return !(lhs == rhs)
  }

  static func != (lhs: When<Value?>, rhs: When<Value?>) -> Bool {
    return !(lhs == rhs)
  }
}

public func == <Value: Equatable>(lhs: [When<Value>], rhs: [When<Value>]) -> Bool {
  if lhs.count != rhs.count { return false }
  for (l, r) in zip(lhs, rhs) where l != r { return false }
  return true
}

public func == <Value: Equatable>(lhs: [When<Value?>], rhs: [When<Value?>]) -> Bool {
  if lhs.count != rhs.count { return false }
  for (l, r) in zip(lhs, rhs) where l != r { return false }
  return true
}

public func != <Value: Equatable>(lhs: [When<Value>], rhs: [When<Value>]) -> Bool {
  return !(lhs == rhs)
}

public func != <Value: Equatable>(lhs: [When<Value?>], rhs: [When<Value?>]) -> Bool {
  return !(lhs == rhs)
}

/// Helper function to wrap the results of `ObjCPromise.when` with the safe `When` enum.
public func asWhen<Value>(_ value: AnyObject) -> When<Value> {
  switch value {
  case let error as NSError:
    return .error(error)
  case let value:
    guard let value = Promise<Value>.asValue(value) else { preconditionFailure() }
    return .value(value)
  }
}
