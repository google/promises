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

#import "FBLPromise+Race.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseRaceTests : XCTestCase
@end

@implementation FBLPromiseRaceTests

- (void)testPromiseRace {
  // Arrange.
  FBLPromise<NSNumber *> *promise1 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@42);
        });
      }];
  FBLPromise<NSString *> *promise2 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(1, ^{
          fulfill(@"hello world");
        });
      }];
  FBLPromise<NSArray<NSNumber *> *> *promise3 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(2, ^{
          fulfill(@[ @42 ]);
        });
      }];
  FBLPromise *promise4 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(3, ^{
          fulfill(nil);
        });
      }];

  // Act.
  FBLPromise *fastestPromise =
      [[FBLPromise race:@[ promise1, promise2, promise3, promise4 ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceRejectFirst {
  // Arrange.
  FBLPromise<NSNumber *> *promise1 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(1, ^{
          fulfill(@42);
        });
      }];
  FBLPromise<NSString *> *promise2 =
      [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }];

  // Act.
  FBLPromise *fastestPromise = [[[FBLPromise race:@[ promise1, promise2 ]] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(fastestPromise.error.code, 42);
  XCTAssertNil(fastestPromise.value);
}

- (void)testPromiseRaceRejectLast {
  // Arrange.
  FBLPromise<NSNumber *> *promise1 =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@42);
        });
      }];
  FBLPromise<NSString *> *promise2 =
      [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }];

  // Act.
  FBLPromise *fastestPromise =
      [[FBLPromise race:@[ promise1, promise2 ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceWithValues {
  // Arrange.
  FBLPromise<NSArray<NSNumber *> *> *promise =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FBLPromise *fastestPromise =
      [[FBLPromise race:@[ @42, @"hello world", promise ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceWithErrorFirst {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  FBLPromise<NSArray<NSNumber *> *> *promise =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FBLPromise *fastestPromise =
      [[[FBLPromise race:@[ promise, error, @42 ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(fastestPromise.error.code, 42);
  XCTAssertNil(fastestPromise.value);
}

- (void)testPromiseRaceWithErrorLast {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  FBLPromise<NSArray<NSNumber *> *> *promise =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FBLPromise *fastestPromise =
      [[FBLPromise race:@[ promise, @42, error ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

/**
 Promise created with `race` should not deallocate until it gets resolved.
 */
- (void)testPromiseRaceNoDeallocUntilResolved {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [FBLPromise race:@[ promise ]];
    weakExtendedPromise2 = [FBLPromise race:@[ promise ]];
    XCTAssertNotNil(weakExtendedPromise1);
    XCTAssertNotNil(weakExtendedPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakExtendedPromise1);
  XCTAssertNotNil(weakExtendedPromise2);

  [promise fulfill:@42];
  XCTAssert(FBLWaitForPromisesWithTimeout(10));

  XCTAssertNil(weakExtendedPromise1);
  XCTAssertNil(weakExtendedPromise2);
}

@end
