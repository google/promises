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


#import "FBLPromise+Observer.h"

@implementation FBLPromiseObserver
{
    FBLPromiseOnFulfillBlock _fulfillBlock;
    FBLPromiseOnRejectBlock _rejectBlock;
}

- (void)fulfill:(nullable id)value {
    if (_fulfillBlock) {
        _fulfillBlock(value);
    }
}

- (void)reject:(nullable NSError *)error {
    if (_rejectBlock) {
        _rejectBlock(error);
    }
}

- (void)registerSignalFulfill:(FBLPromiseOnFulfillBlock)fulfill reject:(FBLPromiseOnRejectBlock)rejct {
    _fulfillBlock = fulfill;
    _rejectBlock = rejct;
}

- (void)unregister {
    _fulfillBlock = nil;
    _rejectBlock = nil;
}

@end

@interface FBLPromise ()
- (void)observeOnQueue:(dispatch_queue_t)queue
               fulfill:(FBLPromiseOnFulfillBlock)onFulfill
                reject:(FBLPromiseOnRejectBlock)onReject NS_SWIFT_UNAVAILABLE("");
@end

@implementation FBLPromise (Observer)
- (instancetype)addObserver:(FBLPromiseObserver *)observer {
    return [self onQueue:self.class.defaultDispatchQueue addObserver:observer];
}

- (instancetype)onQueue:(dispatch_queue_t)queue addObserver:(FBLPromiseObserver *)observer {
    NSParameterAssert(queue);
    NSParameterAssert(observer);
    
    [self observeOnQueue:queue fulfill:^(id  _Nullable value) {
        [observer fulfill:value];
    } reject:^(NSError * _Nonnull error) {
        [observer reject:error];
    }];
    return self;
}
@end

@implementation FBLPromise (DotSyntax_ObserverAdditions)
- (FBLPromise* (^)(FBLPromiseObserver *))addObserver {
  return ^(FBLPromiseObserver *observer) {
    return [self addObserver:observer];
  };
}
@end
