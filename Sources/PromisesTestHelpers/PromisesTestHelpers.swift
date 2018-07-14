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

/// Namespace for test helpers.
public struct Test {

  /// Executes `work` after a time `interval` on the main queue.
  public static func delay(_ interval: TimeInterval, work: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
      work()
    }
  }

  // Phony errors.
  public enum Error: Int, CustomNSError {
    case code13 = 13
    case code42 = 42

    public static var errorDomain: String {
      return "com.google.Promises.Test.Error"
    }

    public var errorCode: Int { return rawValue }

    public var errorUserInfo: [String: Any] { return [:] }
  }
}

/// Convenience `NSError` accessors for `Error` protocol.
public extension Error {
  var domain: String { return (self as NSError).domain }
  var code: Int { return (self as NSError).code }
  var userInfo: [String: Any] { return (self as NSError).userInfo }
}

/// Compare two `Error?`.
public func == (lhs: Error?, rhs: Error?) -> Bool {
  switch (lhs, rhs) {
  case (nil, nil):
    return true
  case (nil, _?), (_?, nil):
    return false
  case let (lhs?, rhs?):
    return (lhs as NSError).isEqual(rhs as NSError)
  }
}

public func != (lhs: Error?, rhs: Error?) -> Bool {
  return !(lhs == rhs)
}

/// Compare two arrays of the same generic type conforming to `Equatable` protocol.
public func == <T: Equatable>(lhs: [T?], rhs: [T?]) -> Bool {
  if lhs.count != rhs.count { return false }
  for (l, r) in zip(lhs, rhs) where l != r { return false }
  return true
}

public func != <T: Equatable>(lhs: [T?], rhs: [T?]) -> Bool {
  return !(lhs == rhs)
}
