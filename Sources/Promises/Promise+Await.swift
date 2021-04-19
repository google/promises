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

/// Waits for promise resolution. The current thread blocks until the promise is resolved.
/// - parameters:
///   - promise: Promise to wait for.
/// - throws: Error the promise was rejected with.
/// - returns: Value the promise was fulfilled with.
public func awaitPromise<Value>(_ promise: Promise<Value>) throws -> Value {
  var outError: NSError?
  let outValue = __FBLPromiseAwait(promise.objCPromise, &outError) as AnyObject
  if let error = outError { throw error }
  guard let value = Promise<Value>.asValue(outValue) else { preconditionFailure() }
  return value
}
