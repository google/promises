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

#import "FBLPromise+Catch.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Do.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseCatchTests : XCTestCase
@end

@implementation FBLPromiseCatchTests

- (void)testPromiseDoesNotCallThenAfterReject {
  // Act.
  FBLPromise *promise = [[[[[FBLPromise do:^id {
    return [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseDoesNotCallThenAfterAsyncReject {
  // Act.
  FBLPromise *promise =
      [[[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseCallsSubsequentCatchAfterReject {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise *promise = [[[[[FBLPromise do:^id {
    return [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
    ++count;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
    ++count;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
    ++count;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseCallsSubsequentCatchAfterAsyncReject {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise *promise =
      [[[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseNoRejectAfterFulfill {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
        fulfill(@42);
        reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }] catch:^(NSError __unused *_) {
        XCTFail();
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseNoFulfillAfterReject {
  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[[FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
        reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        fulfill(@42);
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseNoDoubleReject {
  // Act.
  FBLPromise *promise =
      [[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:13 userInfo:nil]);
        });
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseThenReturnError {
  // Act.
  FBLPromise *promise = [[[[[FBLPromise do:^id {
    return @42;
  }] then:^id(id __unused _) {
    return [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

- (void)testPromiseCatchInitiallyRejected {
  // Act.
  FBLPromise<NSNumber *> *initiallyRejectedPromise = [FBLPromise
      resolvedWith:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
  FBLPromise<NSNumber *> *promise = [[initiallyRejectedPromise then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(initiallyRejectedPromise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(initiallyRejectedPromise.error.code, 42);
  XCTAssertNil(initiallyRejectedPromise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

/**
 Promise created with `catch` should not deallocate until it gets resolved.
 */
- (void)testPromiseCatchNoDeallocUntilRejected {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise catch:^(NSError __unused *_){}];
    weakExtendedPromise2 = [promise catch:^(NSError __unused *_){}];
    XCTAssertNotNil(weakExtendedPromise1);
    XCTAssertNotNil(weakExtendedPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakExtendedPromise1);
  XCTAssertNotNil(weakExtendedPromise2);

  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
  XCTAssert(FBLWaitForPromisesWithTimeout(10));

  XCTAssertNil(weakExtendedPromise1);
  XCTAssertNil(weakExtendedPromise2);
}

@end
