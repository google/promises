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

  /// Validates a fulfilled value or rejects the value if it can not be validated.
  /// - parameters:
  ///   - queue: A queue to dispatch on.
  ///   - predicate: An expression to validate.
  /// - returns: A new pending promise that gets either resolved with same resolution as `self` or
  ///            rejected with `PromiseError.validationFailure` error.
  @discardableResult
  public func validate(
    on queue: DispatchQueue = .promises,
    _ predicate: @escaping (Value) -> Bool
  ) -> Promise {
    let promise = Promise(objCPromise.__onQueue(
      queue,
      validate: { objCValue in
        guard let value = Promise<Value>.asValue(objCValue) else {
          preconditionFailure("Cannot cast \(type(of: objCValue)) to \(Value.self)")
        }
#if (swift(>=4.1) || (!swift(>=4.0) && swift(>=3.3)))
        return predicate(value)
#else
        return ObjCBool(predicate(value))
#endif  // (swift(>=4.1) || (!swift(>=4.0) && swift(>=3.3)))
      }
    ))
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__pendingObjects?.add(promise)
    return promise
  }
}
