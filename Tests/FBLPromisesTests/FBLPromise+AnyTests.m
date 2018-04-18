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

#import "FBLPromise+Any.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseAnyTests : XCTestCase
@end

@implementation FBLPromiseAnyTests

- (void)testPromiseAny {
  // Arrange.
  NSArray *expectedValues = @[ @42, @"hello world", @[ @42 ], [NSNull null] ];
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
  FBLPromise<NSArray *> *combinedPromise =
      [[FBLPromise any:@[ promise1, promise2, promise3, promise4 ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValues);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValues);
  XCTAssertNil(combinedPromise.error);
}

- (void)testPromiseAnyEmpty {
  // Act.
  FBLPromise<NSArray *> *promise = [[FBLPromise any:@[]] then:^id(NSArray *value) {
    XCTAssertEqualObjects(value, @[]);
    return value;
  }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @[]);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAnyRejectFirst {
  // Arrange.
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  NSArray *expectedValuesAndErrors = @[ @42, expectedError ];
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
  FBLPromise<NSArray *> *combinedPromise =
      [[FBLPromise any:@[ promise1, promise2 ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValuesAndErrors);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValuesAndErrors);
  XCTAssertNil(combinedPromise.error);
}

- (void)testPromiseAnyRejectLast {
  // Arrange.
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  NSArray *expectedValuesAndErrors = @[ @42, expectedError ];
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
  FBLPromise<NSArray *> *combinedPromise =
      [[FBLPromise any:@[ promise1, promise2 ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValuesAndErrors);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValuesAndErrors);
  XCTAssertNil(combinedPromise.error);
}

- (void)testPromiseAnyRejectAll {
  // Arrange.
  FBLPromise<NSNumber *> *promise1 =
      [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:13 userInfo:nil]);
        });
      }];
  FBLPromise<NSString *> *promise2 =
      [FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }];

  // Act.
  FBLPromise<NSArray *> *combinedPromise =
      [[[FBLPromise any:@[ promise1, promise2 ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(combinedPromise.error.code, 42);
  XCTAssertNil(combinedPromise.value);
}

- (void)testPromiseAnyWithValuesAndErrors {
  // Arrange.
  NSError *expectedError = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  NSArray *expectedValues = @[ @42, expectedError, @[ @42 ] ];
  FBLPromise<NSArray<NSNumber *> *> *promise =
      [FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  FBLPromise<NSArray *> *combinedPromise =
      [[FBLPromise any:@[ @42, error, promise ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValues);
        return value;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValues);
  XCTAssertNil(combinedPromise.error);
}

/**
 Promise created with `any` should not deallocate until it gets resolved.
 */
- (void)testPromiseAnyNoDeallocUntilResolved {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [FBLPromise any:@[ promise ]];
    weakExtendedPromise2 = [FBLPromise any:@[ promise ]];
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
