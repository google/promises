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

#import "FBLPromise+Async.h"

#import "FBLPromisePrivate.h"

@implementation FBLPromise (AsyncAdditions)

+ (instancetype)async:(FBLPromiseAsyncWorkBlock)work {
  return [self onQueue:self.defaultDispatchQueue
         progressUnits:1
                 async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject,
                         NSProgress *__unused _) {
                   work(fulfill, reject);
                 }];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue async:(FBLPromiseAsyncWorkBlock)work {
  return [self onQueue:queue
         progressUnits:1
                 async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject,
                         NSProgress *__unused _) {
                   work(fulfill, reject);
                 }];
}

+ (instancetype)progressUnits:(int64_t)totalUnitCount async:(FBLPromiseAsyncProgressWorkBlock)work {
  return [self onQueue:self.defaultDispatchQueue progressUnits:totalUnitCount async:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
          progressUnits:(int64_t)totalUnitCount
                  async:(FBLPromiseAsyncProgressWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(totalUnitCount > 0);
  NSParameterAssert(work);

  FBLPromise *promise = [[FBLPromise alloc] initPending];
  promise.progress.totalUnitCount = totalUnitCount;
  dispatch_group_async(FBLPromise.dispatchGroup, queue, ^{
    work(
        ^(id __nullable value) {
          if ([value isKindOfClass:[FBLPromise class]]) {
            [(FBLPromise *)value observeOnQueue:queue
                fulfill:^(id __nullable value) {
                  [promise fulfill:value];
                }
                reject:^(NSError *error) {
                  [promise reject:error];
                }];
          } else {
            [promise fulfill:value];
          }
        },
        ^(NSError *error) {
          [promise reject:error];
        },
        promise.progress);
  });
  return promise;
}

@end

@implementation FBLPromise (DotSyntax_AsyncAdditions)

+ (FBLPromise* (^)(FBLPromiseAsyncWorkBlock))async {
  return ^(FBLPromiseAsyncWorkBlock work) {
    return [self async:work];
  };
}

+ (FBLPromise* (^)(dispatch_queue_t, FBLPromiseAsyncWorkBlock))asyncOn {
  return ^(dispatch_queue_t queue, FBLPromiseAsyncWorkBlock work) {
    return [self onQueue:queue async:work];
  };
}

+ (FBLPromise* (^)(int64_t, FBLPromiseAsyncProgressWorkBlock))asyncProgress {
  return ^(int64_t totalUnitCount, FBLPromiseAsyncProgressWorkBlock work) {
    return [self progressUnits:totalUnitCount async:work];
  };
}

+ (FBLPromise* (^)(dispatch_queue_t, int64_t, FBLPromiseAsyncProgressWorkBlock))asyncProgressOn {
  return ^(dispatch_queue_t queue, int64_t totalUnitCount, FBLPromiseAsyncProgressWorkBlock work) {
    return [self onQueue:queue progressUnits:totalUnitCount async:work];
  };
}

@end
