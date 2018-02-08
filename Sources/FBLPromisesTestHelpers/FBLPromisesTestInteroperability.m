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

#import "FBLPromisesTestInteroperability.h"

#import "FBLPromises.h"
#import "FBLPromisesTestHelpers.h"

@implementation FBLPromisesTestInteroperabilityObjC

+ (FBLPromise *)fulfillWithObject:(nullable id)object {
  return [self fulfillWithObject:object delay:0.0];
}

+ (FBLPromise *)fulfillWithObject:(nullable id)object delay:(NSTimeInterval)delay {
  return [self promiseWithValue:object error:nil delay:delay];
}

+ (FBLPromise *)rejectWithError:(NSError *)error {
  return [self rejectWithError:error delay:0.0];
}

+ (FBLPromise *)rejectWithError:(NSError *)error delay:(NSTimeInterval)delay {
  return [self promiseWithValue:nil error:error delay:delay];
}

#pragma mark - Private

/**
 Returns a promise which gets resolved after a delay either with a given error,
 or with a value, if error is nil.
 */
+ (FBLPromise *)promiseWithValue:(nullable id)value
                          error:(NSError *__nullable)error
                          delay:(NSTimeInterval)delay {
  return [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    FBLDelay(delay, ^{
      if (error) {
        reject(error);
      } else {
        fulfill(value);
      }
    });
  }];
}

@end
