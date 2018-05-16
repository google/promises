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

#import "FBLPromise+Then.h"

#import "FBLPromisePrivate.h"

@implementation FBLPromise (ThenAdditions)

- (FBLPromise *)then:(FBLPromiseThenWorkBlock)work {
  return [self onQueue:FBLPromise.defaultDispatchQueue
         progressUnits:1
                  then:^id(id value, NSProgress *__unused _) {
                    return work(value);
                  }];
}

- (FBLPromise *)onQueue:(dispatch_queue_t)queue then:(FBLPromiseThenWorkBlock)work {
  return [self onQueue:queue
         progressUnits:1
                  then:^id(id value, NSProgress *__unused _) {
                    return work(value);
                  }];
}

- (FBLPromise *)progressUnits:(int64_t)totalUnitCount then:(FBLPromiseThenProgressWorkBlock)work {
  return [self onQueue:FBLPromise.defaultDispatchQueue progressUnits:totalUnitCount then:work];
}

- (FBLPromise *)onQueue:(dispatch_queue_t)queue
          progressUnits:(int64_t)totalUnitCount
                   then:(FBLPromiseThenProgressWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(totalUnitCount > 0);
  NSParameterAssert(work);

  return [self chainOnQueue:queue
              progressUnits:totalUnitCount
             chainedFulfill:work
              chainedReject:nil];
}

@end

@implementation FBLPromise (DotSyntax_ThenAdditions)

- (FBLPromise* (^)(FBLPromiseThenWorkBlock))then {
  return ^(FBLPromiseThenWorkBlock work) {
    return [self then:work];
  };
}

- (FBLPromise* (^)(dispatch_queue_t, FBLPromiseThenWorkBlock))thenOn {
  return ^(dispatch_queue_t queue, FBLPromiseThenWorkBlock work) {
    return [self onQueue:queue then:work];
  };
}

- (FBLPromise* (^)(int64_t, FBLPromiseThenProgressWorkBlock))thenProgress {
  return ^(int64_t totalUnitCount, FBLPromiseThenProgressWorkBlock work) {
    return [self progressUnits:totalUnitCount then:work];
  };
}

- (FBLPromise* (^)(dispatch_queue_t, int64_t, FBLPromiseThenProgressWorkBlock))thenProgressOn {
  return ^(dispatch_queue_t queue, int64_t totalUnitCount, FBLPromiseThenProgressWorkBlock work) {
    return [self onQueue:queue progressUnits:totalUnitCount then:work];
  };
}

@end
