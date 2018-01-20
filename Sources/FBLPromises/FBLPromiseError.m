/**
 Copyright 2018 Google Inc. All rights reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FBLPromiseErrorPrivate.h"

NSString *const FBLPromiseErrorDomain = @"com.google.FBLPromises.Error";
NSString *const FBLPromiseErrorUserInfoExceptionNameKey = @"NSExceptionName";
NSString *const FBLPromiseErrorUserInfoExceptionReasonKey = @"NSExceptionReason";
NSString *const FBLPromiseErrorUserInfoExceptionUserInfoKey = @"NSExceptionUserInfo";
NSString *const FBLPromiseErrorUserInfoExceptionReturnAddressesKey = @"NSExceptionReturnAddresses";
NSString *const FBLPromiseErrorUserInfoExceptionCallStackKey = @"NSExceptionCallStack";

NSError *FBLNSErrorFromNSException(NSException *exception) {
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  userInfo[FBLPromiseErrorUserInfoExceptionNameKey] = exception.name;
  userInfo[FBLPromiseErrorUserInfoExceptionReasonKey] = exception.reason;
  userInfo[FBLPromiseErrorUserInfoExceptionUserInfoKey] = exception.userInfo;
  userInfo[FBLPromiseErrorUserInfoExceptionReturnAddressesKey] = exception.callStackReturnAddresses;
  userInfo[FBLPromiseErrorUserInfoExceptionCallStackKey] = exception.callStackSymbols;
  return [[NSError alloc] initWithDomain:FBLPromiseErrorDomain
                                    code:FBLPromiseErrorCodeException
                                userInfo:userInfo];
}
