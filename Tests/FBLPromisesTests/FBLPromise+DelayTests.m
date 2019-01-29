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

#import "FBLPromise+Delay.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseDelayTests : XCTestCase
@end

@implementation FBLPromiseDelayTests

- (void)testPromiseDelaySuccess {
  // Act.
  FBLPromise<NSNumber *> *promise = [[FBLPromise resolvedWith:@42] delay:0.1];
  [[promise catch:^(NSError __unused *_) {
    XCTFail();
  }] then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    return value;
  }];
  XCTestExpectation *delayedRejectCleanup = [self expectationWithDescription:@""];
  FBLDelay(1, ^{
    [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
    [delayedRejectCleanup fulfill];
  });

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);

  // Cleanup.
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testPromiseDelayFail {
  // Act.
  FBLPromise<NSNumber *> *promise = [[FBLPromise resolvedWith:@42] delay:1];
  XCTestExpectation *delayedResolveCleanup = [self expectationWithDescription:@""];
  FBLDelay(1, ^{
    [delayedResolveCleanup fulfill];
  });
  [[promise catch:^(NSError *error) {
    XCTAssertEqualObjects(error.domain, FBLPromiseErrorDomain);
    XCTAssertEqual(error.code, 42);
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }];
  FBLDelay(0.1, ^{
    [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
  });

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);

  // Cleanup.
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

/**
 Promise created with `delay` should not deallocate until it gets resolved.
 */
- (void)testPromiseDelayNoDeallocUntilResolved {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise delay:1];
    weakExtendedPromise2 = [promise delay:1];
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
