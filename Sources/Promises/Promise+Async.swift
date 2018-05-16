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
  public typealias AsyncProgress = (
    @escaping (Value) -> Void,
    @escaping (Error) -> Void,
    Progress
  ) throws -> Void
  public typealias Async = (@escaping (Value) -> Void, @escaping (Error) -> Void) throws -> Void

  /// Creates a pending promise and executes `work` block asynchronously on the given `queue`.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work: A block to perform any operations needed to resolve the promise.
  public convenience init(
    on queue: DispatchQueue = .promises,
    progressUnits: Int64 = 1,
    _ work: @escaping AsyncProgress
  ) {
    let objCPromise = ObjCPromise<AnyObject>.__onQueue(
      queue,
      progressUnits: progressUnits
    ) { fulfill, reject, progress in
      do {
        try work({ value in
          if let error = value as? NSError {
            reject(error)
          } else {
            fulfill(Promise<Value>.asAnyObject(value))
          }
        }, reject, progress)
      } catch let error {
        reject(error as NSError)
      }
    }
    self.init(objCPromise)
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__pendingObjects?.add(self)
  }

  public convenience init(on queue: DispatchQueue = .promises, _ work: @escaping Async) {
    self.init(on: queue) { fulfill, reject, _ in
      try work(fulfill, reject)
    }
  }
}
