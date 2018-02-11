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

#import "FBLPromise+Resolve.h"

#import "FBLPromise+Async.h"

@implementation FBLPromise (ResolveAdditions)

+ (instancetype)resolveWhenCompleted:(void (^)(FBLPromiseCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    work(^{
      fulfill(nil);
    });
  }];
}

+ (instancetype)resolveWithObjectWhenCompleted:(void (^)(FBLPromiseObjectCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    work(^(id __nullable value) {
      fulfill(value);
    });
  }];
}

+ (instancetype)resolveWithErrorWhenCompleted:(void (^)(FBLPromiseErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(nil);
      }
    });
  }];
}

+ (instancetype)resolveWithObjectOrErrorWhenCompleted:
    (void (^)(FBLPromiseObjectOrErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(id __nullable value, NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(value);
      }
    });
  }];
}

+ (instancetype)resolveWithErrorOrObjectWhenCompleted:
    (void (^)(FBLPromiseErrorOrObjectCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(NSError *__nullable error, id __nullable value) {
      if (error) {
        reject(error);
      } else {
        fulfill(value);
      }
    });
  }];
}

+ (FBLPromise<NSArray *> *)resolveWith2ObjectsOrErrorWhenCompleted:
    (void (^)(FBLPromise2ObjectsOrErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(id __nullable value1, id __nullable value2, NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(@[ value1, value2 ]);
      }
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithBoolWhenCompleted:(void (^)(FBLPromiseBoolCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    work(^(BOOL value) {
      fulfill(@(value));
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithBoolOrErrorWhenCompleted:
    (void (^)(FBLPromiseBoolOrErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(BOOL value, NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(@(value));
      }
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithIntegerWhenCompleted:
    (void (^)(FBLPromiseIntegerCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    work(^(NSInteger value) {
      fulfill(@(value));
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithIntegerOrErrorWhenCompleted:
    (void (^)(FBLPromiseIntegerOrErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(NSInteger value, NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(@(value));
      }
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithDoubleWhenCompleted:
    (void (^)(FBLPromiseDoubleCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
    work(^(double value) {
      fulfill(@(value));
    });
  }];
}

+ (FBLPromise<NSNumber *> *)resolveWithDoubleOrErrorWhenCompleted:
    (void (^)(FBLPromiseDoubleOrErrorCompletion))work {
  NSParameterAssert(work);

  return [self async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
    work(^(double value, NSError *__nullable error) {
      if (error) {
        reject(error);
      } else {
        fulfill(@(value));
      }
    });
  }];
}

@end

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
