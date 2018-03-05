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

#import "FBLPromise+Always.h"

#import <XCTest/XCTest.h>

#import "FBLPromise+Async.h"
#import "FBLPromise+Catch.h"
#import "FBLPromise+Testing.h"
#import "FBLPromise+Then.h"
#import "FBLPromisesTestHelpers.h"

@interface FBLPromiseAlwaysTests : XCTestCase
@end

@implementation FBLPromiseAlwaysTests

- (void)testPromiseAlwaysOnFulfilled {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock __unused _) {
        FBLDelay(0.1, ^{
          fulfill(@42);
        });
      }] always:^{
        ++count;
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }] always:^{
        ++count;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAlwaysOnRejected {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FBLPromise<NSNumber *> *promise =
      [[[[FBLPromise async:^(FBLPromiseFulfillBlock __unused _, FBLPromiseRejectBlock reject) {
        FBLDelay(0.1, ^{
          reject([NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }] always:^{
        ++count;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
        ++count;
      }] always:^{
        ++count;
      }];

  // Assert.
  XCTAssert(FBLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

/**
 Promise created with `always` should not deallocate until it gets resolved.
 */
- (void)testPromiseAlwaysNoDeallocUntilResolved {
  // Arrange.
  FBLPromise *promise = [FBLPromise pendingPromise];
  FBLPromise __weak *weakExtendedPromise1;
  FBLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise always:^{}];
    weakExtendedPromise2 = [promise always:^{}];
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
