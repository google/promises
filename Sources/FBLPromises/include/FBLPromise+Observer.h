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

typedef void (^FBLPromiseOnFulfillBlock)(id __nullable value) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseOnRejectBlock)(NSError *error) NS_SWIFT_UNAVAILABLE("");

@interface FBLPromiseObserver : NSObject
- (void)fulfill:(nullable id)value;
- (void)reject:(nullable NSError *)error;
- (void)registerSignalFulfill:(FBLPromiseOnFulfillBlock)fulfill reject:(FBLPromiseOnRejectBlock)rejct;
- (void)unregister;
@end

@interface FBLPromise (Observer)
- (instancetype)addObserver:(FBLPromiseObserver *)observer;
@end

@interface FBLPromise<Value>(DotSyntax_ObserverAdditions)
- (FBLPromise* (^)(FBLPromiseObserver *))addObserver FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
@end
NS_ASSUME_NONNULL_END
