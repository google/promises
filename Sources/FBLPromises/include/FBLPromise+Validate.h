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

#import "FBLPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBLPromise<Value>(ValidateAdditions)

/**
 Validates a fulfilled value or rejects the value if it can not be validated.

 @param predicate An expression to validate.
 @return A new pending promise that gets either resolved with same resolution as the receiver or
         rejected with `FBLPromiseErrorCodeValidationFailure` error code in `FBLPromiseErrorDomain`.
 */
- (FBLPromise *)validate:(BOOL (^)(Value __nullable))predicate NS_SWIFT_UNAVAILABLE("");

/**
 Validates a fulfilled value or rejects the value if it can not be validated.

 @param queue A queue to dispatch on.
 @param predicate An expression to validate.
 @return A new pending promise that gets either resolved with same resolution as the receiver or
         rejected with `FBLPromiseErrorCodeValidationFailure` error code in `FBLPromiseErrorDomain`.
 */
- (FBLPromise *)onQueue:(dispatch_queue_t)queue
               validate:(BOOL (^)(Value __nullable))predicate NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
