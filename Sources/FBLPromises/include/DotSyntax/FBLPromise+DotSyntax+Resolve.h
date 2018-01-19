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

#import "DotSyntax/FBLPromise+DotSyntax.h"
#import "FBLPromise+Resolve.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Convenience dot-syntax wrappers for `FBLPromise` `resolve` operators.
 Usage: promise.resolveWhen(^(FBLPromiseCompletion handler) {...})
 */
@interface FBLPromise<Value>(DotSyntax_ResolveAdditions)

+ (FBLPromise* (^)(void (^)(FBLPromiseCompletion)))resolveWhen FBL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise* (^)(void (^)(FBLPromiseObjectCompletion)))resolveWithObjectWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise* (^)(void (^)(FBLPromiseErrorCompletion)))resolveWithErrorWhen FBL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise* (^)(void (^)(FBLPromiseObjectOrErrorCompletion)))resolveWithObjectOrErrorWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSArray*>* (^)(void (^)(FBLPromise2ObjectsOrErrorCompletion)))
    resolveWith2ObjectsOrErrorWhen FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseBoolCompletion)))resolveWithBoolWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseBoolOrErrorCompletion)))resolveWithBoolOrErrorWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseIntegerCompletion)))resolveWithIntegerWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseIntegerOrErrorCompletion)))
    resolveWithIntegerOrErrorWhen FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseDoubleCompletion)))resolveWithDoubleWhen
    FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FBLPromise<NSNumber*>* (^)(void (^)(FBLPromiseDoubleOrErrorCompletion)))
    resolveWithDoubleOrErrorWhen FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
