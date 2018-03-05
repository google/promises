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

#import "FBLPromise+Recover.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseRecoverTests : XCTestCase
@end

@implementation FBLPromiseRecoverTests

- (void)testPromiseRecover {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] recover:^id(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
        return
            [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
              FBLDelay(0.1, ^{
                ++count;
                fulfill(@42);
              });
            }];
      }] catch:^(NSError __unused *_) {
        XCTFail();
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseValueRecover {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 2;

  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] recover:^id(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
        return @42;
      }] catch:^(NSError __unused *_) {
        XCTFail();
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseRejectRecover {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] recover:^id(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
        return
            [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
              FBLDelay(0.1, ^{
                ++count;
                reject([NSError errorWithDomain:FBLPromiseErrorDomain code:13 userInfo:nil]);
              });
            }];
      }] then:^id(NSNumber __unused *_) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 13);
        ++count;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqual(promise.error.code, 13);
  XCTAssertNil(promise.value);
}

/**
 Promise created with `recover` should not deallocate until it gets resolved.
 */
- (void)testPromiseRecoverNoDeallocUntilResolved {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise recover:^id(NSError __unused * _) {
      return @42;
    }];
    weakExtendedPromise2 = [promise recover:^id(NSError __unused * _) {
      return @42;
    }];
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
