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

#import "DotSyntax/FBLPromise+DotSyntax+Resolve.h"

@implementation FBLPromise (DotSyntax_ResolveAdditions)

+ (FBLPromise * (^)(void (^)(FBLPromiseCompletion)))resolveWhen {
  return ^(void (^work)(FBLPromiseCompletion)) {
    return [self resolveWhenCompleted:work];
  };
}

+ (FBLPromise * (^)(void (^)(FBLPromiseObjectCompletion)))resolveWithObjectWhen {
  return ^(void (^work)(FBLPromiseObjectCompletion)) {
    return [self resolveWithObjectWhenCompleted:work];
  };
}

+ (FBLPromise * (^)(void (^)(FBLPromiseErrorCompletion)))resolveWithErrorWhen {
  return ^(void (^work)(FBLPromiseErrorCompletion)) {
    return [self resolveWithErrorWhenCompleted:work];
  };
}

+ (FBLPromise * (^)(void (^)(FBLPromiseObjectOrErrorCompletion)))resolveWithObjectOrErrorWhen {
  return ^(void (^work)(FBLPromiseObjectOrErrorCompletion)) {
    return [self resolveWithObjectOrErrorWhenCompleted:work];
  };
}

+ (FBLPromise<NSArray *> * (^)(void (^)(FBLPromise2ObjectsOrErrorCompletion)))
    resolveWith2ObjectsOrErrorWhen {
  return ^(void (^work)(FBLPromise2ObjectsOrErrorCompletion)) {
    return [self resolveWith2ObjectsOrErrorWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseBoolCompletion)))resolveWithBoolWhen {
  return ^(void (^work)(FBLPromiseBoolCompletion)) {
    return [self resolveWithBoolWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseBoolOrErrorCompletion)))
    resolveWithBoolOrErrorWhen {
  return ^(void (^work)(FBLPromiseBoolOrErrorCompletion)) {
    return [self resolveWithBoolOrErrorWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseIntegerCompletion)))resolveWithIntegerWhen {
  return ^(void (^work)(FBLPromiseIntegerCompletion)) {
    return [self resolveWithIntegerWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseIntegerOrErrorCompletion)))
    resolveWithIntegerOrErrorWhen {
  return ^(void (^work)(FBLPromiseIntegerOrErrorCompletion)) {
    return [self resolveWithIntegerOrErrorWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseDoubleCompletion)))resolveWithDoubleWhen {
  return ^(void (^work)(FBLPromiseDoubleCompletion)) {
    return [self resolveWithDoubleWhenCompleted:work];
  };
}

+ (FBLPromise<NSNumber *> * (^)(void (^)(FBLPromiseDoubleOrErrorCompletion)))
    resolveWithDoubleOrErrorWhen {
  return ^(void (^work)(FBLPromiseDoubleOrErrorCompletion)) {
    return [self resolveWithDoubleOrErrorWhenCompleted:work];
  };
}

@end
