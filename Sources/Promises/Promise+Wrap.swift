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

/// Provides a convenient way to convert methods that use common callback patterns into `Promise`s.

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with no arguments.
/// - returns: A new pending promise to be resolved with `nil` when completion handler finishes.
public func wrap(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping () -> Void) throws -> Void
) -> Promise<Any?> {
  return Promise<Any?>(on: queue) { fulfill, _ in
    try work { fulfill(nil) }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with one argument of generic `Value` type.
/// - returns: A new pending promise to be resolved with the value provided by completion handler
///            when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Value) -> Void) throws -> Void
) -> Promise<Value> {
  return Promise<Value>(on: queue) { fulfill, _ in
    try work { fulfill($0) }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with one argument of optional generic `Value` type.
/// - returns: A new pending promise to be resolved with the value or error provided by completion
///            handler when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Value?) -> Void) throws -> Void
) -> Promise<Value?> {
  return Promise<Value?>(on: queue) { fulfill, _ in
    try work { fulfill($0) }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with two arguments: a generic of `Value` type and
///                   an optional `Error`.
/// - returns: A new pending promise to be resolved with the value or error provided by completion
///            handler when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Value, Error?) -> Void) throws -> Void
) -> Promise<Value> {
  return Promise<Value>(on: queue) { fulfill, reject in
    try work { value, error in
      if let error = error {
        reject(error)
      } else {
        fulfill(value)
      }
    }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with two arguments: an optional `Error` and a generic of
///                   `Value` type.
/// - returns: A new pending promise to be resolved with the error or value provided by completion
///            handler when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Error?, Value) -> Void) throws -> Void
) -> Promise<Value> {
  return Promise<Value>(on: queue) { fulfill, reject in
    try work { error, value in
      if let error = error {
        reject(error)
      } else {
        fulfill(value)
      }
    }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with two arguments: an optional generic of `Value` type
///                   and an optional `Error`.
/// - returns: A new pending promise to be resolved with the value or error provided by completion
///            handler when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Value?, Error?) -> Void) throws -> Void
) -> Promise<Value?> {
  return Promise<Value?>(on: queue) { fulfill, reject in
    try work { value, error in
      if let error = error {
        reject(error)
      } else {
        fulfill(value)
      }
    }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with two arguments: an optional `Error` and an optional
///                   generic of `Value` type.
/// - returns: A new pending promise to be resolved with the error or value provided by completion
///            handler when it finishes.
public func wrap<Value>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Error?, Value?) -> Void) throws -> Void
) -> Promise<Value?> {
  return Promise<Value?>(on: queue) { fulfill, reject in
    try work { error, value in
      if let error = error {
        reject(error)
      } else {
        fulfill(value)
      }
    }
  }
}

/// Creates a new promise to be resolved when completion handler gets invoked.
/// - parameter work: A block to execute asynchronously to invoke some API that requires
///                   a completion handler with three arguments: two optionals of `Any` type
///                   and an optional `Error`.
/// - returns: A new pending promise to be resolved with a tuple of optional values or an error
///            provided by completion handler when it finishes.
public func wrap<Value1, Value2>(
  on queue: DispatchQueue = .promises,
  _ work: @escaping (@escaping (Value1?, Value2?, Error?) -> Void) throws -> Void
) -> Promise<(Value1?, Value2?)> {
  return Promise<(Value1?, Value2?)>(on: queue) { fulfill, reject in
    try work { value1, value2, error in
      if let error = error {
        reject(error)
      } else {
        fulfill((value1, value2))
      }
    }
  }
}
