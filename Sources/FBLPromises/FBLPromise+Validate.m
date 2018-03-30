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

#import "FBLPromise+Validate.h"

#import "FBLPromisePrivate.h"

@implementation FBLPromise (ValidateAdditions)

- (FBLPromise *)validate:(BOOL (^)(id __nullable))predicate {
  return [self onQueue:FBLPromise.defaultDispatchQueue validate:predicate];
}

- (FBLPromise *)onQueue:(dispatch_queue_t)queue validate:(BOOL (^)(id __nullable))predicate {
  NSParameterAssert(queue);
  NSParameterAssert(predicate);

  FBLPromiseChainedFulfillBlock chainedFulfill = ^id(id value) {
    return predicate(value) ? value : [NSError errorWithDomain:FBLPromiseErrorDomain
                                                          code:FBLPromiseErrorCodeValidationFailure
                                                      userInfo:nil];
  };
  return [self chainOnQueue:queue chainedFulfill:chainedFulfill chainedReject:nil];
}

@end

@implementation FBLPromise (DotSyntax_ValidateAdditions)

- (FBLPromise* (^)(BOOL (^)(id __nullable)))validate {
  return ^(BOOL (^predicate)(id __nullable)) {
    return [self validate:predicate];
  };
}

- (FBLPromise* (^)(dispatch_queue_t, BOOL (^)(id __nullable)))validateOn {
  return ^(dispatch_queue_t queue, BOOL (^predicate)(id __nullable)) {
    return [self onQueue:queue validate:predicate];
  };
}

@end
