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

extension DispatchGroup {
  /// Dispatch group for promises that is typically used to wait for all scheduled blocks.
  static var promises: DispatchGroup { return Promise<Any>.ObjCPromise<AnyObject>.__dispatchGroup }
}

/// Waits for all scheduled promise blocks.
/// - parameter timeout: Maximum time to wait.
/// - returns: `true` if all promise blocks have completed before `timeout` and `false` otherwise.
func waitForPromises(timeout: TimeInterval) -> Bool {
  return __FBLWaitForPromisesWithTimeout(timeout)
}
