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
  typealias Async = (@escaping (Value) -> Void, @escaping (Error) -> Void) throws -> Void

  /// Creates a pending promise and executes `work` block asynchronously on the given `queue`.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work: A block to perform any operations needed to resolve the promise.
  convenience init(on queue: DispatchQueue = .promises, _ work: @escaping Async) {
    let objCPromise = ObjCPromise<AnyObject>.__onQueue(queue) { fulfill, reject in
      do {
        try work({ value in
          if type(of: value) is NSError.Type {
            reject(value as! NSError)
          } else {
            fulfill(Promise<Value>.asAnyObject(value))
          }
        }, reject)
      } catch let error {
        reject(error as NSError)
      }
    }
    self.init(objCPromise)
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__addPendingObject(self)
  }
}

#if swift(>=5.5)
#if canImport(_Concurrency)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Promise {
	func async() async throws -> Value {
		try await withCheckedThrowingContinuation { continuation in
			then { value in
				continuation.resume(returning: value)
			}.catch { error in
				continuation.resume(throwing: error)
			}
		}
	}
}

public extension Task {
	func asPromise() -> Promise<Success> {
		Promise<Success> { fulfill, reject in
			fulfill(try await self.value)
		}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Promise {
	typealias SwiftAsync = (@escaping (Value) -> Void, @escaping (Error) -> Void) async throws -> Void
	
	/// Creates a pending promise and executes `work` block asynchronously on the given `queue`.
	/// - parameters:
	///   - queue: A queue to invoke the `work` block on.
	///   - work: A block to perform any operations needed to resolve the promise.
	convenience init(on queue: DispatchQueue = .promises, _ work: @escaping SwiftAsync) {
		let objCPromise = ObjCPromise<AnyObject>.__onQueue(queue) { fulfill, reject in
			Task {
				do {
					try await work({ value in
						if type(of: value) is NSError.Type {
							reject(value as! NSError)
						} else {
							fulfill(Promise<Value>.asAnyObject(value))
						}
					}, reject)
				} catch let error {
					reject(error as NSError)
				}
			}
		}
		self.init(objCPromise)
		// Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
		objCPromise.__addPendingObject(self)
	}
}

#endif
#endif
