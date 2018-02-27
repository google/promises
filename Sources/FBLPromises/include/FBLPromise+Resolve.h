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

/**
 Different types of completion handlers available to be wrapped with promise.
 */
typedef void (^FBLPromiseCompletion)(void) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseObjectCompletion)(id __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseErrorCompletion)(NSError* __nullable error) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseObjectOrErrorCompletion)(id __nullable, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseErrorOrObjectCompletion)(NSError* __nullable, id __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromise2ObjectsOrErrorCompletion)(id __nullable, id __nullable,
                                                    NSError* __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseBoolCompletion)(BOOL) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseBoolOrErrorCompletion)(BOOL, NSError* __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseIntegerCompletion)(NSInteger) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseIntegerOrErrorCompletion)(NSInteger, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseDoubleCompletion)(double) NS_SWIFT_UNAVAILABLE("");
typedef void (^FBLPromiseDoubleOrErrorCompletion)(double, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");

/**
 Provides an easy way to convert methods that use common callback patterns into promises.
 */
@interface FBLPromise<Value>(ResolveAdditions)

/**
 @returns A promise that resolves with `nil` when completion handler is invoked.
 */
+ (instancetype)resolveWhenCompleted:(void (^)(FBLPromiseCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an object provided by completion handler.
 */
+ (instancetype)resolveWithObjectWhenCompleted:(void (^)(FBLPromiseObjectCompletion))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an error provided by completion handler.
 If error is `nil`, fulfills with `nil`, otherwise rejects with the error.
 */
+ (instancetype)resolveWithErrorWhenCompleted:(void (^)(FBLPromiseErrorCompletion))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an object provided by completion handler if error is `nil`.
 Otherwise, rejects with the error.
 */
+ (instancetype)resolveWithObjectOrErrorWhenCompleted:
    (void (^)(FBLPromiseObjectOrErrorCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an error or object provided by completion handler. If error
 is not `nil`, rejects with the error.
 */
+ (instancetype)resolveWithErrorOrObjectWhenCompleted:
    (void (^)(FBLPromiseErrorOrObjectCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an array of objects provided by completion handler in order
 if error is `nil`. Otherwise, rejects with the error.
 */
+ (FBLPromise<NSArray*>*)resolveWith2ObjectsOrErrorWhenCompleted:
    (void (^)(FBLPromise2ObjectsOrErrorCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO.
 */
+ (FBLPromise<NSNumber*>*)resolveWithBoolWhenCompleted:(void (^)(FBLPromiseBoolCompletion))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FBLPromise<NSNumber*>*)resolveWithBoolOrErrorWhenCompleted:
    (void (^)(FBLPromiseBoolOrErrorCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping an integer.
 */
+ (FBLPromise<NSNumber*>*)resolveWithIntegerWhenCompleted:
    (void (^)(FBLPromiseIntegerCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping an integer when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FBLPromise<NSNumber*>*)resolveWithIntegerOrErrorWhenCompleted:
    (void (^)(FBLPromiseIntegerOrErrorCompletion))work NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping a double.
 */
+ (FBLPromise<NSNumber*>*)resolveWithDoubleWhenCompleted:(void (^)(FBLPromiseDoubleCompletion))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @returns A promise that resolves with an `NSNumber` wrapping a double when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FBLPromise<NSNumber*>*)resolveWithDoubleOrErrorWhenCompleted:
    (void (^)(FBLPromiseDoubleOrErrorCompletion))work NS_SWIFT_UNAVAILABLE("");

@end

/**
 Convenience dot-syntax wrappers for `FBLPromise` `resolve` operators.
 Usage: FBLPromise.resolveWhen(^(FBLPromiseCompletion handler) {...})
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
