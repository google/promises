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

/// Promises synchronization construct in Swift. Leverages ObjC implementation internally.
public final class Promise<Value> {
  public typealias ObjCPromise<T: AnyObject> = FBLPromise<T>

  /// Creates a new promise with an existing ObjC promise.
  public init<T>(_ objCPromise: ObjCPromise<T>) {
    guard let objCPromise = objCPromise as? ObjCPromise<AnyObject> else {
      preconditionFailure("Cannot cast \(T.self) to \(AnyObject.self)")
    }
    self.objCPromise = objCPromise
  }

  /// Creates a new pending promise.
  public static func pending() -> Promise<Value> {
    return Promise<Value>.init(ObjCPromise<AnyObject>.__pending())
  }

  /// Creates a new pending promise.
  public convenience init() {
    self.init(ObjCPromise<AnyObject>.__pending())
  }

  /// Creates a new promise rejected with the given `error`.
  public convenience init(_ error: Error) {
    self.init(ObjCPromise<AnyObject>.__resolved(with: error as NSError))
  }

  /// Creates a new promise resolved with the result of `work` block.
  public convenience init(_ work: @autoclosure () throws -> Value) {
    do {
      let resolution = try work()
      if type(of: resolution) is NSError.Type {
        let error = resolution as! NSError
        self.init(error)
      } else if let objCPromise = resolution as? ObjCPromise<AnyObject> {
          self.init(objCPromise)
      } else {
          self.init(ObjCPromise<AnyObject>.__resolved(with: Promise<Value>.asAnyObject(resolution)))
      }
    } catch let error {
      self.init(error as NSError)
    }
  }

  /// Resolves `self` with the given `resolution`.
  public func fulfill(_ resolution: Value) {
    objCPromise.__fulfill(Promise<Value>.asAnyObject(resolution))
  }

  /// Rejects `self` with the given `error`.
  public func reject(_ error: Error) {
    objCPromise.__fulfill(error as NSError)
  }

  /// Converts `self` into ObjC promise.
  public func asObjCPromise<T>() -> ObjCPromise<T> {
    guard let objCPromise = objCPromise as? ObjCPromise<T> else {
      preconditionFailure("Cannot cast \(AnyObject.self) to \(T.self)")
    }
    return objCPromise
  }

  // MARK: Internal

  /// Underlying ObjC counterpart.
  let objCPromise: ObjCPromise<AnyObject>

  var isPending: Bool { return objCPromise.__isPending }

  var isFulfilled: Bool { return objCPromise.__isFulfilled }

  var isRejected: Bool { return objCPromise.__isRejected }

  var value: Value? {
    let objCValue = objCPromise.__value
    if Promise<AnyObject>.isBridgedNil(objCValue) { return nil }
    guard let value = objCValue as? Value else {
      preconditionFailure("Cannot cast \(type(of: objCValue)) to \(Value.self)")
    }
    return value
  }

  var error: Error? {
    guard let objCPromiseError = objCPromise.__error else { return nil }
    // Convert `NSError` to `PromiseError`, if applicable.
    return PromiseError(objCPromiseError) ?? objCPromiseError
  }

  /// Converts generic `Value` to `AnyObject`.
  static func asAnyObject(_ value: Value) -> AnyObject? {
    return Promise<Value>.isBridgedNil(value) ? nil : value as AnyObject
  }

  /// Converts `AnyObject` to generic `Value`, or `nil` if the conversion is not possible.
  static func asValue(_ value: AnyObject?) -> Value? {
    // Swift nil becomes NSNull during bridging.
    return (value as? Value) ?? NSNull() as AnyObject as? Value
  }

  // MARK: Private

  /// Checks if generic `Value` is bridged ObjC `nil`.
  private static func isBridgedNil(_ value: Value?) -> Bool {
    // Swift nil becomes NSNull during bridging.
    return !(value is NSNull) && (value as AnyObject is NSNull)
  }
}

extension Promise: CustomStringConvertible {
  public var description: String {
    var description = "nil"
    if isFulfilled {
      if let value = value { description = String(describing: value) }
      return "Fulfilled: \(description)"
    }
    if isRejected {
      if let error = error { description = String(describing: error) }
      return "Rejected: \(description)"
    }
    return "Pending: \(Value.self)"
  }
}

public extension DispatchQueue {
  /// Default dispatch queue used for `Promise`, which is `main` if a queue is not specified.
  static var promises: DispatchQueue {
    get { return Promise<Any>.ObjCPromise<AnyObject>.__defaultDispatchQueue }
    set { Promise<Any>.ObjCPromise<AnyObject>.__defaultDispatchQueue = newValue }
  }
}
