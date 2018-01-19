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

/// Internal errors that `Promise` can throw.
/// Indirectly conforms to `Swift.Error` through conformance to `Swift.CustomNSError` below.
/// Not placing it under extension `Promise` for convenience to avoid collisions with `Swift.Error`.
public enum PromiseError {
  case nsException(NSExceptionName, String?, [AnyHashable: Any]?, [NSNumber], [String])
  case timedOut
  case validationFailure
}

/// Downcasting from `Swift.Error` and `NSException`.
extension PromiseError {
  public init?(_ error: Error) {
    let error = error as NSError
    if error.domain != __FBLPromiseErrorDomain { return nil }
    switch error.code {
    case __FBLPromiseErrorCode.exception.rawValue:
      let errorUserInfo = error.userInfo
      guard let name = errorUserInfo[__FBLPromiseErrorUserInfoExceptionNameKey] as? NSExceptionName,
          let returnAddresses: [NSNumber] =
              errorUserInfo[__FBLPromiseErrorUserInfoExceptionReturnAddressesKey] as? [NSNumber],
          let callStack: [String] =
              errorUserInfo[__FBLPromiseErrorUserInfoExceptionCallStackKey] as? [String]
          else { return nil }
      let reason = errorUserInfo[__FBLPromiseErrorUserInfoExceptionReasonKey] as? String
      let userInfo =
          errorUserInfo[__FBLPromiseErrorUserInfoExceptionUserInfoKey] as? [AnyHashable: Any]
      self = .nsException(name, reason, userInfo, returnAddresses, callStack)
    case __FBLPromiseErrorCode.timedOut.rawValue:
      self = .timedOut
    case __FBLPromiseErrorCode.validationFailure.rawValue:
      self = .validationFailure
    default:
      return nil
    }
  }

  public init?(_ nsException: NSException) {
    self = .nsException(nsException.name,
                        nsException.reason,
                        nsException.userInfo,
                        nsException.callStackReturnAddresses,
                        nsException.callStackSymbols)
  }
}

extension PromiseError: CustomNSError {
  public static var errorDomain: String {
    return __FBLPromiseErrorDomain
  }

  public var errorCode: Int {
    switch self {
    case .nsException:
      return __FBLPromiseErrorCode.exception.rawValue
    case .timedOut:
      return __FBLPromiseErrorCode.timedOut.rawValue
    case .validationFailure:
      return __FBLPromiseErrorCode.validationFailure.rawValue
    }
  }

  public var errorUserInfo: [String: Any] {
    if case let .nsException(name, reason, userInfo, returnAddresses, callStack) = self {
      return [
        __FBLPromiseErrorUserInfoExceptionNameKey: name,
        __FBLPromiseErrorUserInfoExceptionReasonKey: reason as Any,
        __FBLPromiseErrorUserInfoExceptionUserInfoKey: userInfo as Any,
        __FBLPromiseErrorUserInfoExceptionReturnAddressesKey: returnAddresses,
        __FBLPromiseErrorUserInfoExceptionCallStackKey: callStack
      ]
    }
    return [String: Any]()
  }
}

extension PromiseError: Equatable {
  public static func == (lhs: PromiseError, rhs: PromiseError) -> Bool {
    return (lhs as NSError).isEqual(rhs as NSError)
  }
}
