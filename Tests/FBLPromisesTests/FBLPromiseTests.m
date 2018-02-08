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

#import <XCTest/XCTest.h>

#import "FBLPromise+Testing.h"

@interface FBLPromiseTests : XCTestCase
@end

@implementation FBLPromiseTests

/**
 New pending promise should have pending state and no value or error.
 */
- (void)testPromiseConstructorPending {
  // Arrange & Act.
  FBLPromise *promise = [FBLPromise pendingPromise];

  // Assert.
  XCTAssertTrue(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNotNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

/**
 New promise resolved with a value should have that value set and not be pending or have an error.
 */
- (void)testPromiseConstructorResolvedWithValue {
  // Arrange & Act.
  FBLPromise *promise = [FBLPromise resolvedWith:@42];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 New promise resolved with an error should have that error set and not be pending or have a value.
 */
- (void)testPromiseConstructorResolvedWithError {
  // Arrange & Act.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  FBLPromise *promise = [FBLPromise resolvedWith:error];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 New promise resolved with another pending promise should have its value set to nil and not be
 pending or have an error.
 */
- (void)testPromiseConstructorResolvedWithPendingPromise {
  // Arrange & Act.
  FBLPromise *anotherPromise = [FBLPromise pendingPromise];
  FBLPromise *promise = [FBLPromise resolvedWith:anotherPromise];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

/**
 New promise resolved with another fulfilled promise should have its value set and not be pending or
 have an error.
 */
- (void)testPromiseConstructorResolvedWithFulfilledPromise {
  // Arrange & Act.
  FBLPromise *anotherPromise = [FBLPromise resolvedWith:@42];
  FBLPromise *promise = [FBLPromise resolvedWith:anotherPromise];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 New promise resolved with another rejected promise should have its error set and not be pending or
 have a value.
 */
- (void)testPromiseConstructorResolvedWithRejectedPromise {
  // Arrange & Act.
  NSError *error = [NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil];
  FBLPromise *anotherPromise = [FBLPromise resolvedWith:error];
  FBLPromise *promise = [FBLPromise resolvedWith:anotherPromise];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 Fulfilling a pending promise should set its value and have no error.
 */
- (void)testPromiseFulfill {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise fulfill:@42];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 Subsequent fulfilling a pending promise has no effect.
 */
- (void)testPromiseNoDoubleFulfill {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise fulfill:@42];
  [promise fulfill:@13];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 Fulfilling a pending promise with error should reject it.
 */
- (void)testPromiseFulfillWithError {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise fulfill:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 Rejecting a pending promise should set its error and have no value.
 */
- (void)testPromiseReject {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 Subsequent rejecting a pending promise has no effect.
 */
- (void)testPromiseNoDoubleReject {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:13 userInfo:nil]];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 Rejecting a promise after it has been fulfilled has no effect.
 */
- (void)testPromiseNoRejectAfterFulfill {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise fulfill:@42];
  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:13 userInfo:nil]];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertFalse(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 Fulfilling a promise after it has been rejected has no effect.
 */
- (void)testPromiseNoFulfillAfterReject {
  // Arrange.
  FBLPromise<NSNumber *> *promise = [FBLPromise pendingPromise];

  // Act.
  [promise reject:[NSError errorWithDomain:FBLPromiseErrorDomain code:42 userInfo:nil]];
  [promise fulfill:@13];

  // Assert.
  XCTAssertFalse(promise.isPending);
  XCTAssertFalse(promise.isFulfilled);
  XCTAssertTrue(promise.isRejected);
  XCTAssertNil(promise.pendingObjects);
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FBLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

/**
 Pending promise should not deallocate when nothing refers to it.
 */
- (void)testPromisePendingDealloc {
  FBLPromise __weak *weakPromise;

  @autoreleasepool {
    XCTAssertNil(weakPromise);
    FBLPromise *promise = [FBLPromise pendingPromise];
    weakPromise = promise;
    XCTAssertNotNil(weakPromise);
  }
  XCTAssertNil(weakPromise);
}

@end
