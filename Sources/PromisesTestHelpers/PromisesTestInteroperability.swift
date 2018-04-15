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
import Promises

@objc(FBLPromisesTestInteroperabilitySwift)
public class Interoperability: NSObject {
  @objc
  public static func fulfill(
    _ object: Any?,
    delay: TimeInterval
  ) -> Promise<Any?>.ObjCPromise<AnyObject> {
    return promise(object, error: nil, delay: delay).asObjCPromise()
  }

  @objc
  public static func fulfill(
    number: NSNumber?,
    delay: TimeInterval
  ) -> Promise<NSNumber?>.ObjCPromise<NSNumber> {
    return promise(number, error: nil, delay: delay).asObjCPromise()
  }

  @objc
  public static func reject(
    _ error: Error,
    delay: TimeInterval
  ) -> Promise<Any?>.ObjCPromise<AnyObject> {
    return (promise(nil, error: error, delay: delay) as Promise<Any?>).asObjCPromise()
  }

  @objc
  public static func `throw`(
    _ error: Error,
    delay: TimeInterval
  ) -> Promise<Any?>.ObjCPromise<AnyObject> {
    return (
      promise(nil, error: error, shouldThrow: true, delay: delay) as Promise<Any?>
    ).asObjCPromise()
  }

  // MARK: Internal

  static func promise<T>(
    _ value: T,
    error: Error? = nil,
    shouldThrow: Bool = false,
    delay: TimeInterval = 0.0
  ) -> Promise<T> {
    return Promise { fulfill, reject in
      if let error = error, shouldThrow {
        Thread.sleep(forTimeInterval: delay)
        throw error
      }
      Test.delay(delay) {
        if let error = error {
          reject(error)
        } else {
          fulfill(value)
        }
      }
    }
  }
}
