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

#import "FBLPromiseProgressPrivate.h"

#import "FBLPromise.h"

@implementation FBLPromiseProgress {
  FBLPromise __weak *_promise;
  NSHashTable<FBLPromiseProgress *> *_syncProgresses;
}

- (instancetype)initWithParent:(NSProgress *)parentProgressOrNil
                      userInfo:(NSDictionary<NSProgressUserInfoKey,id> *)userInfoOrNil {
  self = [super initWithParent:parentProgressOrNil userInfo:userInfoOrNil];
  if (self) {
    NSPointerFunctionsOptions options =
        NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality;
    _syncProgresses = [[NSHashTable alloc] initWithOptions:options capacity:1];
  }
  return self;
}

- (void)addSyncProgress:(FBLPromiseProgress *)progress {
  @synchronized(self) {
    [_syncProgresses addObject:progress];
  }
}

#pragma mark NSProgress

- (void)setCompletedUnitCount:(int64_t)completedUnitCount {
  @synchronized(self) {
    super.completedUnitCount = completedUnitCount;
    for (FBLPromiseProgress *progress in _syncProgresses) {
      progress.completedUnitCount = completedUnitCount;
    }
  }
}

- (void)setTotalUnitCount:(int64_t)totalUnitCount {
  @synchronized(self) {
    super.totalUnitCount = totalUnitCount;
    for (FBLPromiseProgress *progress in _syncProgresses) {
      progress.totalUnitCount = totalUnitCount;
    }
  }
}

- (void)cancel {
  @synchronized(self) {
    if (!self.isCancelled) {
      [super cancel];
      for (FBLPromiseProgress *progress in _syncProgresses) {
        progress.cancellationHandler = nil;
        [progress cancel];
      }
    }
    [_promise reject:[[NSError alloc] initWithDomain:FBLPromiseErrorDomain
                                                code:FBLPromiseErrorCodeCancelled
                                            userInfo:nil]];
  }
}

@end
